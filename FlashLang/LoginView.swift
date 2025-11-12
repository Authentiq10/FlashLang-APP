//
//  LoginView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authCoordinator: AuthCoordinator
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignup = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email
        case password
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.92, blue: 1.0), // Light purple
                        Color(red: 0.98, green: 0.96, blue: 1.0), // Very light purple
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            // App logo/icon
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.6, green: 0.4, blue: 0.9), // Purple
                                                Color(red: 0.7, green: 0.5, blue: 1.0)  // Light purple
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3), radius: 12, x: 0, y: 6)
                                
                                Image(systemName: "graduationcap.fill")
                                    .font(.system(size: 48, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Welcome Back!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.4, green: 0.2, blue: 0.8), // Dark purple
                                                Color(red: 0.6, green: 0.4, blue: 0.9)  // Purple
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Sign in to continue learning German")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            }
                        }
                        .padding(.top, 40)
                        
                        // Login form
                        VStack(spacing: 24) {
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                        .frame(width: 20)
                                    
                                    TextField("Enter your email", text: $email)
                                        .font(.system(size: 16, weight: .regular))
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .focused($focusedField, equals: .email)
                                        .onChange(of: email) { oldValue, newValue in
                                            validateEmail()
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            emailError.isEmpty ? Color.clear : Color.red.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                
                                if !emailError.isEmpty {
                                    Text(emailError)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.red)
                                        .padding(.leading, 4)
                                }
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                        .frame(width: 20)
                                    
                                    SecureField("Enter your password", text: $password)
                                        .font(.system(size: 16, weight: .regular))
                                        .textContentType(.password)
                                        .focused($focusedField, equals: .password)
                                        .onChange(of: password) { oldValue, newValue in
                                            validatePassword()
                                        }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            passwordError.isEmpty ? Color.clear : Color.red.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                
                                if !passwordError.isEmpty {
                                    Text(passwordError)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.red)
                                        .padding(.leading, 4)
                                }
                            }
                            
                            // Login button
                            Button(action: signIn) {
                                HStack(spacing: 12) {
                                    if authCoordinator.authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    
                                    Text(authCoordinator.authService.isLoading ? "Signing In..." : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.6, green: 0.4, blue: 0.9), // Purple
                                            Color(red: 0.7, green: 0.5, blue: 1.0)  // Light purple
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(authCoordinator.authService.isLoading || !isFormValid)
                            .opacity(isFormValid ? 1.0 : 0.6)
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign up link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            
                            Button("Sign Up") {
                                showingSignup = true
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignup) {
                UnifiedAuthView()
                    .environmentObject(authCoordinator)
            }
            .alert("Login Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && emailError.isEmpty && passwordError.isEmpty
    }
    
    private func validateEmail() {
        let result = authCoordinator.authService.validateEmail(email)
        emailError = result.errorMessage ?? ""
    }
    
    private func validatePassword() {
        let result = authCoordinator.authService.validatePassword(password)
        passwordError = result.errorMessage ?? ""
    }
    
    private func signIn() {
        guard isFormValid else { return }
        
        Task {
            let result = await authCoordinator.authService.signIn(email: email, password: password)
            
            await MainActor.run {
                switch result {
                case .success(let user):
                    print("Successfully signed in: \(user.email)")
                    // The AuthService will automatically update the auth state
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
} 