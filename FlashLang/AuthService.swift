//
//  AuthService.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import Foundation
import Combine

class AuthService: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let sessionKey = "supabase_session"
    
    // Supabase configuration (temporary fallback)
    private var supabaseUrl: String = ""
    private var supabaseAnonKey: String = ""
    
    init() {
        // Set initial state to loading
        self.authState = .loading
        
        // Load session and update state
        loadSession()
        
        // Try to refresh session if we have a stored session
        if let _ = loadStoredSession() {
            Task {
                let refreshed = await refreshSession()
                if !refreshed {
                    // If refresh fails, clear the session
                    await MainActor.run {
                        self.clearSession()
                    }
                }
            }
        }
    }
    
    // MARK: - Configuration
    func configure(supabaseUrl: String, supabaseAnonKey: String) {
        self.supabaseUrl = supabaseUrl
        self.supabaseAnonKey = supabaseAnonKey
    }
    
    // MARK: - Authentication Methods
    func signUp(email: String, fullName: String, password: String) async -> Result<AuthUser, Error> {
        isLoading = true
        
        let url = URL(string: "\(supabaseUrl)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": [
                "full_name": fullName
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Debug: Print the request details
            print("🔍 Signup Request Details:")
            print("URL: \(url)")
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Body: \(body)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("📡 Signup Response Status: \(response)")
            print("📄 Signup Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
            print("🔍 Full Response Object: \(response)")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Signup HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    print("✅ Success status code: \(httpResponse.statusCode)")
                    
                    // Check if this is a signup response with email confirmation required
                    if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("🔍 Response data keys: \(responseData.keys)")
                        print("🔍 Full response data: \(responseData)")
                        
                        // Check for confirmation_sent_at field (indicates email confirmation required)
                        if let confirmationSentAt = responseData["confirmation_sent_at"] as? String,
                           !confirmationSentAt.isEmpty {
                            print("📧 Confirmation sent at: \(confirmationSentAt)")
                            print("🎯 RETURNING EMAIL CONFIRMATION REQUIRED ERROR")
                            await MainActor.run {
                                self.isLoading = false
                            }
                            return .failure(AuthError(message: "Account created successfully! Please check your email and click the confirmation link before signing in.", status: httpResponse.statusCode, errorCode: "email_confirmation_required"))
                        }
                        
                        // Check if user exists but session is null (another indication of email confirmation required)
                        if let _ = responseData["user"] as? [String: Any],
                           responseData["session"] == nil || (responseData["session"] as? NSNull) != nil {
                            print("📧 User created but no session - email confirmation required")
                            print("🎯 RETURNING EMAIL CONFIRMATION REQUIRED ERROR (session null)")
                            await MainActor.run {
                                self.isLoading = false
                            }
                            return .failure(AuthError(message: "Account created successfully! Please check your email and click the confirmation link before signing in.", status: httpResponse.statusCode, errorCode: "email_confirmation_required"))
                        }
                    }
                    
                    print("🔍 Attempting to decode response...")
                    
                    // Try to decode as AuthUser first (when email confirmation is disabled)
                    if let user = try? JSONDecoder().decode(AuthUser.self, from: data) {
                        print("✅ User decoded successfully: \(user.email)")
                        await MainActor.run {
                            self.currentUser = user
                            self.authState = .authenticated(user)
                            // Create a minimal session for the user
                            let session = Session(accessToken: "", refreshToken: "", expiresIn: 3600, tokenType: "bearer")
                            self.saveSession(user: user, session: session)
                            self.isLoading = false
                        }
                        return .success(user)
                    }
                    
                    // Try to decode as AuthResponse (when email confirmation is enabled)
                    if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                        print("✅ AuthResponse decoded successfully")
                        print("🔍 User: \(authResponse.user?.email ?? "nil")")
                        print("🔍 Session: \(authResponse.session != nil ? "present" : "nil")")
                        
                        if let user = authResponse.user, let session = authResponse.session {
                            await MainActor.run {
                                self.currentUser = user
                                self.authState = .authenticated(user)
                                self.saveSession(user: user, session: session)
                                self.isLoading = false
                            }
                            return .success(user)
                        } else {
                            await MainActor.run {
                                self.isLoading = false
                            }
                            return .failure(AuthError(message: "User creation failed", status: httpResponse.statusCode, errorCode: nil))
                        }
                    } else {
                        // If we can't decode as standard models, but we have a success status code,
                        // this likely means email confirmation is required
                        print("⚠️ Failed to decode as standard models - checking for email confirmation requirement")
                        await MainActor.run {
                            self.isLoading = false
                        }
                        return .failure(AuthError(message: "Account created successfully! Please check your email and click the confirmation link before signing in.", status: httpResponse.statusCode, errorCode: "email_confirmation_required"))
                    }
                } else {
                    // Try to decode error response
                    if let errorResponse = try? JSONDecoder().decode(AuthError.self, from: data) {
                        // Handle email confirmation case
                        if errorResponse.errorCode == "email_not_confirmed" {
                            await MainActor.run {
                                self.isLoading = false
                            }
                            return .failure(AuthError(message: "Please check your email and confirm your account before signing in", status: httpResponse.statusCode, errorCode: "email_not_confirmed"))
                        }
                        await MainActor.run {
                            self.isLoading = false
                        }
                        return .failure(errorResponse)
                    } else {
                        // Try to decode as a different error format
                        if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let errorCode = errorData["error_code"] as? String {
                                // Handle specific error codes
                                switch errorCode {
                                case "user_already_exists":
                                    await MainActor.run {
                                        self.isLoading = false
                                    }
                                    return .failure(AuthError(message: "This email is already registered. Please try signing in instead.", status: httpResponse.statusCode, errorCode: errorCode))
                                default:
                                    if let error = errorData["msg"] as? String {
                                        await MainActor.run {
                                            self.isLoading = false
                                        }
                                        return .failure(AuthError(message: error, status: httpResponse.statusCode, errorCode: errorCode))
                                    }
                                }
                            } else if let error = errorData["error"] as? String {
                                await MainActor.run {
                                    self.isLoading = false
                                }
                                return .failure(AuthError(message: error, status: httpResponse.statusCode, errorCode: nil))
                            }
                        }
                        
                        // Try to get the raw response as string
                        let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                        await MainActor.run {
                            self.isLoading = false
                        }
                        return .failure(AuthError(message: "Registration failed: \(responseString)", status: httpResponse.statusCode, errorCode: nil))
                    }
                }
            }
            
            return .failure(AuthError(message: "Unknown error", status: nil, errorCode: nil))
        } catch {
            print("Signup Error: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(AuthError(message: error.localizedDescription, status: nil, errorCode: nil))
        }
    }
    
    func signIn(email: String, password: String) async -> Result<AuthUser, Error> {
        isLoading = true
        
        let url = URL(string: "\(supabaseUrl)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Debug: Print the request details
            print("🔍 Signin Request Details:")
            print("URL: \(url)")
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Body: \(body)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("📡 Signin Response Status: \(response)")
            print("📄 Signin Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Signin HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("🔍 Attempting to decode signin response...")
                    
                    // Try to decode as signin response format first
                    if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let accessToken = responseData["access_token"] as? String,
                       let userData = responseData["user"] as? [String: Any],
                       let userEmail = userData["email"] as? String {
                        
                        print("✅ Signin response decoded successfully")
                        
                        // Create user object
                        let userMetadata = userData["user_metadata"] as? [String: Any]
                        let user = AuthUser(
                            id: userData["id"] as? String ?? "",
                            email: userEmail,
                            fullName: userMetadata?["full_name"] as? String,
                            createdAt: userData["created_at"] as? String ?? "",
                            updatedAt: userData["updated_at"] as? String ?? ""
                        )
                        
                        // Create session object
                        let session = Session(
                            accessToken: accessToken,
                            refreshToken: responseData["refresh_token"] as? String ?? "",
                            expiresIn: responseData["expires_in"] as? Int ?? 3600,
                            tokenType: responseData["token_type"] as? String ?? "bearer"
                        )
                        
                        await MainActor.run {
                            self.currentUser = user
                            self.authState = .authenticated(user)
                            self.saveSession(user: user, session: session)
                            self.isLoading = false
                        }
                        return .success(user)
                    }
                    
                    // Fallback to AuthResponse format
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    if let user = authResponse.user, let session = authResponse.session {
                        await MainActor.run {
                            self.currentUser = user
                            self.authState = .authenticated(user)
                            self.saveSession(user: user, session: session)
                            self.isLoading = false
                        }
                        return .success(user)
                    } else {
                        await MainActor.run {
                            self.isLoading = false
                        }
                        return .failure(AuthError(message: "Login failed", status: httpResponse.statusCode, errorCode: nil))
                    }
                } else {
                    // Try to decode error response
                    if let errorResponse = try? JSONDecoder().decode(AuthError.self, from: data) {
                        // Handle email confirmation case
                        if errorResponse.errorCode == "email_not_confirmed" {
                            return .failure(AuthError(message: "Please check your email and confirm your account before signing in", status: httpResponse.statusCode, errorCode: "email_not_confirmed"))
                        }
                        return .failure(errorResponse)
                    } else {
                        // Try to decode as a different error format
                        if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = errorData["error"] as? String {
                            await MainActor.run {
                                self.isLoading = false
                            }
                            return .failure(AuthError(message: error, status: httpResponse.statusCode, errorCode: nil))
                        } else {
                            // Try to get the raw response as string
                            let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                            await MainActor.run {
                                self.isLoading = false
                            }
                            return .failure(AuthError(message: "Authentication failed: \(responseString)", status: httpResponse.statusCode, errorCode: nil))
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(AuthError(message: "Unknown error", status: nil, errorCode: nil))
        } catch {
            print("Signin Error: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(AuthError(message: error.localizedDescription, status: nil, errorCode: nil))
        }
    }
    
    func signOut() async {
        isLoading = true
        
        guard let session = loadStoredSession() else {
            await MainActor.run {
                self.clearSession()
                self.isLoading = false
            }
            return
        }
        
        let url = URL(string: "\(supabaseUrl)/auth/v1/logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 || httpResponse.statusCode == 200 {
                    await MainActor.run {
                        self.clearSession()
                    }
                }
            }
        } catch {
            print("Logout error: \(error)")
        }
        
        await MainActor.run {
            self.clearSession()
            self.isLoading = false
        }
    }
    
    func refreshSession() async -> Bool {
        guard let session = loadStoredSession() else {
            return false
        }
        
        let url = URL(string: "\(supabaseUrl)/auth/v1/token?grant_type=refresh_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "apikey")
        
        let body = [
            "refresh_token": session.refreshToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    if let user = authResponse.user, let newSession = authResponse.session {
                        await MainActor.run {
                            self.currentUser = user
                            self.authState = .authenticated(user)
                            self.saveSession(user: user, session: newSession)
                        }
                        return true
                    }
                }
            }
        } catch {
            print("Session refresh error: \(error)")
        }
        
        return false
    }
    
    // MARK: - Session Management
    private func saveSession(user: AuthUser, session: Session? = nil) {
        if let session = session {
            let sessionData = try? JSONEncoder().encode(session)
            userDefaults.set(sessionData, forKey: sessionKey)
        }
        
        let userData = try? JSONEncoder().encode(user)
        userDefaults.set(userData, forKey: "current_user")
    }
    
    private func loadSession() {
        if let userData = userDefaults.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
            self.currentUser = user
            self.authState = .authenticated(user)
            print("📱 Loaded existing user session: \(user.email)")
        } else {
            self.currentUser = nil
            self.authState = .unauthenticated
            print("📱 No existing session found, showing login screen")
        }
    }
    
    private func loadStoredSession() -> Session? {
        guard let sessionData = userDefaults.data(forKey: sessionKey) else {
            return nil
        }
        return try? JSONDecoder().decode(Session.self, from: sessionData)
    }
    
    private func clearSession() {
        userDefaults.removeObject(forKey: sessionKey)
        userDefaults.removeObject(forKey: "current_user")
        self.currentUser = nil
        self.authState = .unauthenticated
    }
    
    // MARK: - Validation
    func validateEmail(_ email: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Email is required")
        } else if !emailPredicate.evaluate(with: email) {
            return ValidationResult(isValid: false, errorMessage: "Please enter a valid email address")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Password is required")
        } else if password.count < 6 {
            return ValidationResult(isValid: false, errorMessage: "Password must be at least 6 characters")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validateConfirmPassword(_ password: String, _ confirmPassword: String) -> ValidationResult {
        if confirmPassword.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Please confirm your password")
        } else if password != confirmPassword {
            return ValidationResult(isValid: false, errorMessage: "Passwords do not match")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    // MARK: - Email Verification Methods
    
    func checkEmailIsVerified(email: String) async -> Result<Bool, Error> {
        await MainActor.run {
            self.isLoading = true
        }
        
        // For pre-signup verification, we'll use a simpler approach
        // In a real implementation, you might check with your backend
        // For now, we'll simulate checking after user clicks the verification link
        do {
            // This is a simplified check - in production you'd verify with your backend
            await MainActor.run {
                self.isLoading = false
            }
            
            // For demo purposes, we'll return false initially and rely on deep link detection
            return .success(false)
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func checkEmailVerification() async -> Result<Bool, Error> {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let url = URL(string: "\(supabaseUrl)/auth/v1/user")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
            
            // If we have a stored session, use it to check the current user
            if let session = loadStoredSession() {
                request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                // No session means user needs to sign in after verification
                await MainActor.run {
                    self.isLoading = false
                }
                return .success(false)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📧 Email verification check status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let emailConfirmedAt = responseData["email_confirmed_at"] as? String?, 
                       emailConfirmedAt != nil {
                        // Email is verified
                        await MainActor.run {
                            self.isLoading = false
                        }
                        return .success(true)
                    } else {
                        // Email not yet verified
                        await MainActor.run {
                            self.isLoading = false
                        }
                        return .success(false)
                    }
                } else if httpResponse.statusCode == 401 {
                    // Session expired or invalid, user needs to verify and sign in again
                    await MainActor.run {
                        self.clearSession()
                        self.isLoading = false
                    }
                    return .success(false)
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            return .success(false)
            
        } catch {
            print("Email verification check error: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func sendPreSignupVerification(email: String) async -> Result<Void, Error> {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let url = URL(string: "\(supabaseUrl)/auth/v1/resend")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            
            let body = [
                "type": "signup",
                "email": email
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 Pre-signup verification response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return .success(())
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return .failure(AuthError(message: "Failed to send verification email", status: httpResponse.statusCode, errorCode: nil))
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(AuthError(message: "No response received", status: nil, errorCode: nil))
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func resendEmailVerification(email: String) async -> Result<Void, Error> {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let url = URL(string: "\(supabaseUrl)/auth/v1/resend")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
            
            let body = [
                "type": "signup",
                "email": email
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 Resend response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return .success(())
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return .failure(AuthError(message: "Failed to resend verification email", status: httpResponse.statusCode, errorCode: nil))
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(AuthError(message: "No response received", status: nil, errorCode: nil))
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func handleEmailConfirmation(url: URL) async -> Result<Void, Error> {
        await MainActor.run {
            self.isLoading = true
        }
        
        print("📱 Processing email confirmation URL: \(url)")
        
        // Extract the tokens from the URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(AuthError(message: "Invalid confirmation URL", status: 400, errorCode: "invalid_url"))
        }
        
        print("🔍 URL components: \(queryItems)")
        
        // Look for tokens in the URL that we can use to authenticate the user
        if let accessToken = queryItems.first(where: { $0.name == "access_token" })?.value,
           let refreshToken = queryItems.first(where: { $0.name == "refresh_token" })?.value {
            
            print("✅ Found full tokens in URL - attempting to authenticate with tokens")
            
            do {
                // Use the tokens to get user information from Supabase
                let url = URL(string: "\(supabaseUrl)/auth/v1/user")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 User info response status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        print("🔍 User info response: \(String(data: data, encoding: .utf8) ?? "No data")")
                        
                        if let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let userEmail = userData["email"] as? String,
                           let userId = userData["id"] as? String {
                            
                            let userMetadata = userData["user_metadata"] as? [String: Any]
                            let authUser = AuthUser(
                                id: userId,
                                email: userEmail,
                                fullName: userMetadata?["full_name"] as? String,
                                createdAt: userData["created_at"] as? String ?? "",
                                updatedAt: userData["updated_at"] as? String ?? ""
                            )
                            
                            await MainActor.run {
                                self.currentUser = authUser
                                self.authState = .authenticated(authUser)
                                
                                // Save the session
                                let session = Session(
                                    accessToken: accessToken,
                                    refreshToken: refreshToken,
                                    expiresIn: 3600,
                                    tokenType: "bearer"
                                )
                                self.saveSession(user: authUser, session: session)
                                self.isLoading = false
                            }
                            
                            print("✅ Email confirmation successful - user authenticated")
                            return .success(())
                        }
                    }
                }
            } catch {
                print("❌ Failed to authenticate with tokens: \(error)")
            }
        }
        
        // Check for specific confirmation tokens (token, type)
        if let token = queryItems.first(where: { $0.name == "token" })?.value,
           let type = queryItems.first(where: { $0.name == "type" })?.value,
           type == "email" {
            
            print("✅ Found email confirmation token - confirming email")
            
            do {
                // Call Supabase to confirm the email using the token
                let url = URL(string: "\(supabaseUrl)/auth/v1/verify")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
                
                let body = [
                    "token": token,
                    "type": type
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 Email verification response status: \(httpResponse.statusCode)")
                    print("🔍 Email verification response: \(String(data: data, encoding: .utf8) ?? "No data")")
                    
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        print("✅ Email verified successfully via API")
                        
                        await MainActor.run {
                            self.isLoading = false
                            NotificationCenter.default.post(name: NSNotification.Name("EmailConfirmationAttempted"), object: nil)
                        }
                        
                        return .success(())
                    }
                }
            } catch {
                print("❌ Failed to verify email with token: \(error)")
            }
        }
        
        // If we don't have recognizable tokens, this might still be a confirmation attempt
        // Post a notification that email confirmation was attempted
        print("🔍 No recognizable tokens found, treating as generic email confirmation attempt")
        await MainActor.run {
            self.isLoading = false
            NotificationCenter.default.post(name: NSNotification.Name("EmailConfirmationAttempted"), object: nil)
        }
        
        return .success(())
    }
} 