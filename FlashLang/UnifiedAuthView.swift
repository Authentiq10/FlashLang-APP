//
//  UnifiedAuthView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

struct UnifiedAuthView: View {
    @EnvironmentObject var authCoordinator: AuthCoordinator
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUpMode = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingEmailVerification = false
    @State private var showEmailVerifiedBanner = false
    @State private var emailVerified = false
    @State private var verificationStep = false // Track if we're in verification step
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email
        case fullName
        case password
        case confirmPassword
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(spacing: 24) {
                            // App Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.6, green: 0.4, blue: 0.9),
                                                Color(red: 0.7, green: 0.5, blue: 1.0)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: isSignUpMode ? "person.badge.plus" : "graduationcap.fill")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 60)
                            
                            // Title and Subtitle
                            VStack(spacing: 8) {
                                Text(isSignUpMode ? "Create Account" : "Welcome Back")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(isSignUpMode ? "Join FlashLang to start learning German" : "Sign in to continue your learning journey")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .padding(.bottom, 40)
                        
                        // Mode Toggle
                        VStack(spacing: 24) {
                            // Segmented Control Style Toggle
                            HStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isSignUpMode = false
                                        clearErrors()
                                    }
                                }) {
                                    Text("Sign In")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(isSignUpMode ? .secondary : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isSignUpMode ? Color(.systemGray6) : Color.accentColor)
                                        )
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isSignUpMode = true
                                        clearErrors()
                                    }
                                }) {
                                    Text("Sign Up")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(isSignUpMode ? .white : .secondary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(isSignUpMode ? Color.accentColor : Color(.systemGray6))
                                        )
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        // Email Verified Banner
                        if showEmailVerifiedBanner {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 20))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Email Verified! ✅")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text("Welcome back! Please sign in to continue.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showEmailVerifiedBanner = false
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 18))
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.95, green: 0.98, blue: 0.95))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 24)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }
                        
                        // Form Section
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .frame(width: 20)
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .focused($focusedField, equals: .email)
                                        .onChange(of: email) { oldValue, newValue in
                                            validateEmail()
                                        }
                                        .onSubmit {
                                            if isSignUpMode {
                                                focusedField = .fullName
                                            } else {
                                                focusedField = .password
                                            }
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(focusedField == .email ? Color.accentColor : Color.clear, lineWidth: 1)
                                )
                                
                                if !emailError.isEmpty {
                                    Text(emailError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, 4)
                                }
                            }
                            
                            // Full Name Field (only for signup)
                            if isSignUpMode {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Full Name")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "person")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .frame(width: 20)
                                        
                                        TextField("Enter your full name", text: $fullName)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .focused($focusedField, equals: .fullName)
                                            .onSubmit {
                                                focusedField = .password
                                            }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(focusedField == .fullName ? Color.accentColor : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .frame(width: 20)
                                    
                                    SecureField("Enter your password", text: $password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .focused($focusedField, equals: .password)
                                        .onChange(of: password) { oldValue, newValue in
                                            validatePassword()
                                        }
                                        .onSubmit {
                                            if isSignUpMode {
                                                focusedField = .confirmPassword
                                            } else {
                                                focusedField = nil
                                                authenticate()
                                            }
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(focusedField == .password ? Color.accentColor : Color.clear, lineWidth: 1)
                                )
                                
                                if !passwordError.isEmpty {
                                    Text(passwordError)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.leading, 4)
                                }
                            }
                            
                            // Confirm Password Field (only for signup)
                            if isSignUpMode {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Confirm Password")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "lock")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .frame(width: 20)
                                        
                                        SecureField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .focused($focusedField, equals: .confirmPassword)
                                            .onChange(of: confirmPassword) { oldValue, newValue in
                                                validateConfirmPassword()
                                            }
                                            .onSubmit {
                                                focusedField = nil
                                                authenticate()
                                            }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(focusedField == .confirmPassword ? Color.accentColor : Color.clear, lineWidth: 1)
                                    )
                                    
                                    if !confirmPasswordError.isEmpty {
                                        Text(confirmPasswordError)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.leading, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Action Button
                        VStack(spacing: 16) {
                            Button(action: authenticate) {
                                HStack(spacing: 8) {
                                    if authCoordinator.authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: isSignUpMode ? "person.badge.plus" : "arrow.right")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    
                                    Text(authCoordinator.authService.isLoading ? 
                                         (isSignUpMode ? "Sending Verification..." : "Signing In...") : 
                                         (isSignUpMode ? "Verify Email & Create Account" : "Sign In"))
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isFormValid ? Color.accentColor : Color(.systemGray4))
                                )
                            }
                            .disabled(authCoordinator.authService.isLoading || !isFormValid)
                            
                            // Terms and Privacy (for signup)
                            if isSignUpMode {
                                Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        
                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Test") {
                        Task {
                            await AuthTest.runManualTest()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                #endif
            }
            .alert(isSignUpMode ? "Sign Up Error" : "Sign In Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .fullScreenCover(isPresented: $showingEmailVerification, onDismiss: {
                // When user returns from email verification, switch to sign-in mode and show banner
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isSignUpMode = false
                        showEmailVerifiedBanner = true
                        clearErrors()
                        verificationStep = false
                        emailVerified = true
                    }
                    
                    // Auto-hide the banner after 8 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showEmailVerifiedBanner = false
                        }
                    }
                }
            }) {
                if isSignUpMode {
                    PreSignupVerificationView(
                        email: email,
                        fullName: fullName,
                        password: password,
                        authCoordinator: authCoordinator
                    )
                    .onAppear {
                        // Ensure loading state is reset when verification view appears
                        DispatchQueue.main.async {
                            authCoordinator.authService.isLoading = false
                        }
                    }
                } else {
                    EmailVerificationView(email: email, authCoordinator: authCoordinator)
                        .onAppear {
                            // Ensure loading state is reset when email verification view appears
                            DispatchQueue.main.async {
                                authCoordinator.authService.isLoading = false
                            }
                        }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        let basicValidation = !email.isEmpty && !password.isEmpty && emailError.isEmpty && passwordError.isEmpty
        
        if isSignUpMode {
            return basicValidation && !fullName.isEmpty && !confirmPassword.isEmpty && confirmPasswordError.isEmpty
        } else {
            return basicValidation
        }
    }
    
    private func clearErrors() {
        emailError = ""
        passwordError = ""
        confirmPasswordError = ""
    }
    
    private func validateEmail() {
        let result = authCoordinator.authService.validateEmail(email)
        emailError = result.errorMessage ?? ""
    }
    
    private func validatePassword() {
        let result = authCoordinator.authService.validatePassword(password)
        passwordError = result.errorMessage ?? ""
    }
    
    private func validateConfirmPassword() {
        let result = authCoordinator.authService.validateConfirmPassword(password, confirmPassword)
        confirmPasswordError = result.errorMessage ?? ""
    }
    
    private func authenticate() {
        guard isFormValid else { return }
        
        Task {
            if isSignUpMode && !verificationStep {
                // First step: Send verification email
                let result = await authCoordinator.authService.sendPreSignupVerification(email: email)
                
                await MainActor.run {
                    switch result {
                    case .success:
                        print("✅ Verification email sent successfully")
                        showingEmailVerification = true
                    case .failure(let error):
                        print("❌ Failed to send verification email: \(error)")
                        alertMessage = "Failed to send verification email: \(error.localizedDescription)"
                        showingAlert = true
                    }
                }
            } else {
                // Regular sign in or verified sign up
                let result: Result<AuthUser, Error>
                
                if isSignUpMode {
                    result = await authCoordinator.authService.signUp(email: email, fullName: fullName, password: password)
                } else {
                    result = await authCoordinator.authService.signIn(email: email, password: password)
                }
                
                await MainActor.run {
                    switch result {
                    case .success(let user):
                        print("Successfully \(isSignUpMode ? "signed up" : "signed in"): \(user.email)")
                        // The AuthService will automatically update the auth state
                    case .failure(let error):
                        print("🚨 Authentication failed with error: \(error)")
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
        }
    }
    

}

#Preview("Auth Flow") {
    // This will show the main content in preview mode due to AuthView's preview bypass logic
    AuthView()
}

#Preview("Login Form") {
    // This shows the actual login form for design purposes
    UnifiedAuthView()
        .environmentObject(AuthCoordinator())
} 