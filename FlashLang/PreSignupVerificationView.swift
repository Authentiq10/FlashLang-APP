
//
//  PreSignupVerificationView.swift
//  FlashLang
//
//  Pre-signup email verification view
//

import SwiftUI
import Combine

struct PreSignupVerificationView: View {
    let email: String
    let fullName: String
    let password: String
    @ObservedObject var authCoordinator: AuthCoordinator
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isCheckingVerification = false
    @State private var resendCooldown = 0
    @State private var timer: Timer?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Email verification icon
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.2, blue: 0.8),
                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Verify Your Email")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Please verify your email address to complete your FlashLang account creation.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Email address display
                VStack(spacing: 8) {
                    Text("Verification email sent to:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(email)
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.2, blue: 0.8),
                                    Color(red: 0.6, green: 0.4, blue: 0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Instructions
                VStack(spacing: 12) {
                    Text("📧 Check your email")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Click the verification link in your email, then return here to complete your registration.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action buttons
                VStack(spacing: 15) {
                    // I've verified button
                    Button(action: checkEmailAndCreateAccount) {
                        HStack {
                            if isCheckingVerification {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isCheckingVerification ? "Checking Verification..." : "I've Verified My Email")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.3),
                                    Color(red: 0.1, green: 0.7, blue: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isCheckingVerification)
                    
                    // Resend email button
                    Button(action: resendVerificationEmail) {
                        HStack {
                            Image(systemName: "envelope.arrow.triangle.branch.fill")
                            Text(resendCooldown > 0 ? "Resend in \(resendCooldown)s" : "Resend Email")
                        }
                        .font(.subheadline)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.2, blue: 0.8),
                                    Color(red: 0.6, green: 0.4, blue: 0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                    .disabled(resendCooldown > 0)
                    
                    // Back button
                    Button("← Back to Sign Up") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startResendCooldown()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EmailConfirmationAttempted"))) { _ in
            print("📧 Received email confirmation notification - user clicked email link")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Automatically try to sign in when deep link is triggered
                // This suggests the user clicked the email verification link
                attemptSignInAfterDeepLink()
            }
        }
        .alert("Verification Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkEmailAndCreateAccount() {
        isCheckingVerification = true
        
        Task {
            print("🔐 User clicked 'I've Verified My Email' - attempting direct sign in")
            
            // Since the user says they've verified their email, try to sign in directly
            // This avoids rate limiting issues with verification endpoints
            let signInResult = await authCoordinator.authService.signIn(email: email, password: password)
            
            await MainActor.run {
                switch signInResult {
                case .success(let user):
                    print("✅ Successfully signed in after email verification: \(user.email)")
                    isCheckingVerification = false
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Direct sign in failed: \(error)")
                    print("❌ Error type: \(type(of: error))")
                    
                    if let authError = error as? AuthError {
                        print("❌ AuthError details - Message: '\(authError.message)', Code: '\(authError.errorCode ?? "nil")', Status: \(authError.status ?? 0)")
                        
                        if authError.errorCode == "email_not_confirmed" {
                            // Email is not confirmed yet - could be timing issue or user hasn't clicked link
                            print("📧 Email not confirmed - trying with retry and guidance")
                            handleEmailNotConfirmed()
                        } else if authError.message.contains("Invalid login credentials") || authError.errorCode == "invalid_credentials" {
                            print("🔄 Account might not exist yet, trying to create it...")
                            createAccountAfterVerification()
                        } else {
                            // Show the error to user
                            isCheckingVerification = false
                            errorMessage = "Sign in failed: \(authError.message)"
                            showingError = true
                        }
                    } else {
                        // Try account creation as fallback
                        print("🔄 Unknown error, trying account creation as fallback...")
                        createAccountAfterVerification()
                    }
                }
            }
        }
    }
    
    private func attemptSignInAfterDeepLink() {
        print("🔗 Attempting sign in after deep link - email should be verified now")
        
        Task {
            // Give a bit more time for Supabase to update the verification status
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 second delay
            
            let signInResult = await authCoordinator.authService.signIn(email: email, password: password)
            
            await MainActor.run {
                switch signInResult {
                case .success(let user):
                    print("✅ Successfully signed in after deep link: \(user.email)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Sign in after deep link failed: \(error)")
                    
                    if let authError = error as? AuthError, authError.errorCode == "email_not_confirmed" {
                        print("📧 Email still not confirmed after deep link - might need manual verification")
                        // Don't show error automatically, user can still try manual button
                    } else {
                        print("❌ Other error after deep link: \(error.localizedDescription)")
                        // Don't show error automatically, user can still try manual button
                    }
                }
            }
        }
    }
    
    private func handleEmailNotConfirmed() {
        print("📧 Handling email not confirmed case...")
        
        Task {
            // First, let's wait a bit in case there's a delay in verification
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 second delay
            
            // Try sign in again
            let retrySignInResult = await authCoordinator.authService.signIn(email: email, password: password)
            
            await MainActor.run {
                switch retrySignInResult {
                case .success(let user):
                    print("✅ Successfully signed in after retry: \(user.email)")
                    isCheckingVerification = false
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Retry sign in also failed: \(error)")
                    
                    if let authError = error as? AuthError, authError.errorCode == "email_not_confirmed" {
                        // Still not confirmed, provide specific guidance
                        isCheckingVerification = false
                        errorMessage = "Please make sure you:\n\n1. Check your email inbox\n2. Click the verification link\n3. Wait for the confirmation page\n4. Then return here and try again\n\nIf you didn't receive the email, use 'Resend Email' below."
                        showingError = true
                    } else {
                        // Try account creation as final fallback
                        print("🔄 Final fallback - trying account creation...")
                        createAccountAfterVerification()
                    }
                }
            }
        }
    }
    
    private func createAccountAfterVerification() {
        Task {
            print("🚀 Creating account after email verification...")
            print("📧 Email: \(email)")
            print("👤 Full Name: \(fullName)")
            
            // Add a delay to avoid rate limiting
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            
            let signUpResult = await authCoordinator.authService.signUp(email: email, fullName: fullName, password: password)
            
            await MainActor.run {
                isCheckingVerification = false
                
                switch signUpResult {
                case .success(let user):
                    print("✅ Account created successfully after verification: \(user.email)")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Account creation after verification failed: \(error)")
                    
                    if let authError = error as? AuthError {
                        if authError.errorCode == "email_confirmation_required" {
                            // Email confirmation required means account was created but needs confirmation
                            // Since user says they verified, dismiss and let them sign in manually
                            print("📧 Account created but still needs confirmation - dismissing")
                            presentationMode.wrappedValue.dismiss()
                        } else if authError.message.contains("already") || authError.errorCode == "user_already_exists" {
                            // User already exists, dismiss and let them sign in manually
                            print("👤 User already exists - dismissing")
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            // Real error occurred
                            errorMessage = "Account setup failed: \(authError.message)"
                            showingError = true
                        }
                    } else {
                        errorMessage = "Account creation failed: \(error.localizedDescription)"
                        showingError = true
                    }
                }
            }
        }
    }
    
    private func createAccount() {
        Task {
            print("🚀 Starting account creation process...")
            print("📧 Email: \(email)")
            print("👤 Full Name: \(fullName)")
            
            // First, try to create the account
            let signUpResult = await authCoordinator.authService.signUp(email: email, fullName: fullName, password: password)
            
            await MainActor.run {
                switch signUpResult {
                case .success(let user):
                    print("✅ Account created successfully with session: \(user.email)")
                    // Account created successfully with session, AuthService will handle auth state
                    isCheckingVerification = false
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("🔍 Account creation failed: \(error)")
                    print("🔍 Error type: \(type(of: error))")
                    
                    if let authError = error as? AuthError {
                        print("🔍 AuthError details - Message: '\(authError.message)', Code: '\(authError.errorCode ?? "nil")', Status: \(authError.status ?? 0)")
                        
                        if authError.errorCode == "email_confirmation_required" {
                            // Account was created but email confirmation is still required - try sign in
                            print("📧 Account exists but email confirmation required - attempting sign in...")
                            attemptSignInAfterVerification()
                        } else if authError.message.contains("already") || authError.errorCode == "user_already_exists" {
                            // User already exists, try to sign in directly
                            print("👤 User already exists - attempting sign in...")
                            attemptSignInAfterVerification()
                        } else {
                            // Real error occurred
                            isCheckingVerification = false
                            errorMessage = "Account setup failed: \(authError.message)"
                            showingError = true
                        }
                    } else {
                        // Non-AuthError
                        isCheckingVerification = false
                        errorMessage = "Account creation failed: \(error.localizedDescription)"
                        showingError = true
                    }
                }
            }
        }
    }
    
    private func attemptSignInAfterVerification() {
        Task {
            print("🔐 Attempting sign in after verification...")
            print("📧 Email: \(email)")
            
            // Add a small delay to ensure the email verification has been processed
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            let signInResult = await authCoordinator.authService.signIn(email: email, password: password)
            
            await MainActor.run {
                isCheckingVerification = false
                
                switch signInResult {
                case .success(let user):
                    print("✅ Successfully signed in after verification: \(user.email)")
                    // User signed in successfully, AuthService will handle auth state
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("❌ Sign in after verification failed: \(error)")
                    print("❌ Error type: \(type(of: error))")
                    
                    if let authError = error as? AuthError {
                        print("❌ AuthError details - Message: '\(authError.message)', Code: '\(authError.errorCode ?? "nil")', Status: \(authError.status ?? 0)")
                        
                        // Show specific error message
                        errorMessage = "Sign in failed: \(authError.message)"
                        showingError = true
                    } else {
                        // If sign in fails, dismiss and let user manually sign in
                        // This provides a fallback in case there are timing issues
                        print("💭 Dismissing view to let user sign in manually")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        // Check if cooldown is active
        guard resendCooldown == 0 else {
            return
        }
        
        Task {
            let result = await authCoordinator.authService.sendPreSignupVerification(email: email)
            
            await MainActor.run {
                switch result {
                case .success:
                    print("✅ Verification email resent")
                    startResendCooldown()
                case .failure(let error):
                    print("❌ Failed to resend email: \(error)")
                    
                    if let authError = error as? AuthError {
                        if authError.message.contains("seconds") || authError.message.contains("rate") {
                            // Rate limiting error
                            errorMessage = "Please wait before requesting another email. \(authError.message)"
                            // Start a longer cooldown to prevent further attempts
                            resendCooldown = 60
                            startResendCooldown()
                        } else {
                            errorMessage = "Failed to resend email: \(authError.message)"
                        }
                    } else {
                        errorMessage = "Failed to resend email: \(error.localizedDescription)"
                    }
                    showingError = true
                }
            }
        }
    }
    
    private func startResendCooldown() {
        resendCooldown = 60 // 60 seconds cooldown
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if resendCooldown > 0 {
                resendCooldown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    PreSignupVerificationView(
        email: "user@example.com",
        fullName: "John Doe",
        password: "password123",
        authCoordinator: AuthCoordinator()
    )
}
