//
//  EmailVerificationView.swift
//  FlashLang
//
//  Email verification view for iOS-native confirmation flow
//

import SwiftUI
import Combine

struct EmailVerificationView: View {
    let email: String
    @ObservedObject var authCoordinator: AuthCoordinator
    @Environment(\.presentationMode) var presentationMode
    
    @State private var verificationStatus: VerificationStatus = .pending
    @State private var isCheckingVerification = false
    @State private var resendCooldown = 0
    @State private var timer: Timer?
    
    enum VerificationStatus {
        case pending
        case verified
        case expired
        case error(String)
    }
    
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
                
                // Email icon and status
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: statusColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: statusIcon)
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 12) {
                        Text(statusTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(statusMessage)
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
                
                // Action buttons
                VStack(spacing: 15) {
                    switch verificationStatus {
                    case .pending:
                        VStack(spacing: 15) {
                            // Check verification button
                            Button(action: checkEmailVerification) {
                                HStack {
                                    if isCheckingVerification {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    Text(isCheckingVerification ? "Checking..." : "I've Verified My Email")
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
                        }
                        
                    case .verified:
                        VStack(spacing: 15) {
                            // Success message card
                            VStack(spacing: 8) {
                                Text("🎉 All Set!")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("You can now sign in with your verified email address")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color(red: 0.95, green: 0.98, blue: 0.95))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.2, green: 0.8, blue: 0.3).opacity(0.3), lineWidth: 1)
                            )
                            
                            Button(action: proceedToSignIn) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                    Text("Go to Sign In")
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
                        }
                        
                    case .expired, .error:
                        VStack(spacing: 12) {
                            Button(action: resendVerificationEmail) {
                                HStack {
                                    Image(systemName: "envelope.arrow.triangle.branch.fill")
                                    Text("Send New Verification Email")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.4, green: 0.2, blue: 0.8),
                                            Color(red: 0.6, green: 0.4, blue: 0.9)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            Button("Back to Sign Up") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
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
            print("📧 Received email confirmation notification - checking verification status")
            // Automatically check verification status when we receive the confirmation notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                checkEmailVerification()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("📱 App entering foreground - checking email verification status")
            // Check verification status when app comes to foreground (user returning from email)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkEmailVerification()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusColors: [Color] {
        switch verificationStatus {
        case .pending:
            return [Color(red: 0.4, green: 0.2, blue: 0.8), Color(red: 0.6, green: 0.4, blue: 0.9)]
        case .verified:
            return [Color(red: 0.2, green: 0.8, blue: 0.3), Color(red: 0.1, green: 0.7, blue: 0.2)]
        case .expired, .error:
            return [Color(red: 0.9, green: 0.3, blue: 0.3), Color(red: 0.8, green: 0.2, blue: 0.2)]
        }
    }
    
    private var statusIcon: String {
        switch verificationStatus {
        case .pending:
            return "envelope.fill"
        case .verified:
            return "checkmark.seal.fill"
        case .expired:
            return "clock.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var statusTitle: String {
        switch verificationStatus {
        case .pending:
            return "Check Your Email"
        case .verified:
            return "Email Verified! ✅"
        case .expired:
            return "Verification Expired"
        case .error:
            return "Verification Error"
        }
    }
    
    private var statusMessage: String {
        switch verificationStatus {
        case .pending:
            return "We've sent a verification link to your email. Click the link to verify your account, then tap 'I've Verified My Email' below."
        case .verified:
            return "Your email has been successfully verified! Please return to the sign-in screen to access your FlashLang account."
        case .expired:
            return "The verification link has expired. Please request a new verification email."
        case .error(let message):
            return message
        }
    }
    
    // MARK: - Actions
    
    private func checkEmailVerification() {
        isCheckingVerification = true
        
        Task {
            // Check if user's email is verified in Supabase
            let result = await authCoordinator.authService.checkEmailVerification()
            
            await MainActor.run {
                isCheckingVerification = false
                
                switch result {
                case .success(let isVerified):
                    if isVerified {
                        verificationStatus = .verified
                        // Email is verified! User will need to sign in normally
                        // We'll show the success state and let them proceed
                    } else {
                        // Show helpful message for unverified email
                        verificationStatus = .error("Email not yet verified. Please check your email and click the verification link, then try again.")
                    }
                case .failure(let error):
                    verificationStatus = .error("Unable to check verification status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        Task {
            let result = await authCoordinator.authService.resendEmailVerification(email: email)
            
            await MainActor.run {
                switch result {
                case .success:
                    verificationStatus = .pending
                    startResendCooldown()
                case .failure(let error):
                    verificationStatus = .error("Failed to resend email: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func proceedToSignIn() {
        // User's email is verified, dismiss this view and return to sign-in screen
        presentationMode.wrappedValue.dismiss()
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
    EmailVerificationView(email: "user@example.com", authCoordinator: AuthCoordinator())
}
