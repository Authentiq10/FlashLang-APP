//
//  AuthCoordinator.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

class AuthCoordinator: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var currentUser: AuthUser?
    
    let authService = AuthService()
    
    init() {
        setupAuthService()
        
        // Test Supabase connection (remove in production)
        #if DEBUG
        Task {
            await AuthTest.testSupabaseProject()
        }
        #endif
    }
    
    private func setupAuthService() {
        // Configure Supabase with your credentials
        authService.configure(
            supabaseUrl: "https://cyqugaekraiyuwgfejws.supabase.co",
            supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5cXVnYWVrcmFpeXV3Z2ZlandzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MTcwNzksImV4cCI6MjA3MDA5MzA3OX0.0FfjV0TZ6av0r2021rmF-RVcFMLBZaEeKRxhb6njJUc"
        )
        
        // Load existing session and update state
        DispatchQueue.main.async {
            // The AuthService will automatically load the session and update the state
            // We don't need to manually set it to unauthenticated here
        }
        
        // Observe auth state changes
        authService.$authState
            .receive(on: DispatchQueue.main)
            .assign(to: &$authState)
        
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }
    
    func configureSupabase(supabaseUrl: String, supabaseAnonKey: String) {
        authService.configure(supabaseUrl: supabaseUrl, supabaseAnonKey: supabaseAnonKey)
    }
    
    func signOut() async {
        await authService.signOut()
    }
    
    func refreshSession() async -> Bool {
        return await authService.refreshSession()
    }
}

struct AuthView: View {
    @StateObject private var authCoordinator = AuthCoordinator()
    
    var body: some View {
        Group {
            // Preview bypass: Skip authentication in preview mode
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                ContentView()
                    .environmentObject(authCoordinator)
            } else {
                switch authCoordinator.authState {
                case .loading:
                    LoadingView()
                case .authenticated(_):
                    ContentView()
                        .environmentObject(authCoordinator)
                case .unauthenticated:
                    UnifiedAuthView()
                        .environmentObject(authCoordinator)
                case .error(let message):
                    ErrorView(message: message) {
                        authCoordinator.authState = .unauthenticated
                    }
                }
            }
        }
        .environmentObject(authCoordinator)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 24) {
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
                    Text("FlashLang")
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
                    
                    Text("Loading...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 0.4, blue: 0.9)))
                    .scaleEffect(1.2)
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 24) {
                // Error icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red.opacity(0.8),
                                    Color.red.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.red.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Oops!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    
                    Text(message)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button(action: retryAction) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
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
            }
        }
    }
}

#Preview {
    AuthView()
} 