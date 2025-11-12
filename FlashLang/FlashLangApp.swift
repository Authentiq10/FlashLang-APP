//
//  FlashLangApp.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

@main
struct FlashLangApp: App {
    @StateObject private var authCoordinator = AuthCoordinator()
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authCoordinator)
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
        .handlesExternalEvents(matching: ["flashlang"])
    }
    
    private func handleDeepLink(url: URL) {
        print("📱 Received deep link: \(url)")
        
        // Check if this is an email confirmation link
        if url.scheme == "flashlang" && url.host == "auth" {
            print("✅ Processing email confirmation deep link")
            
            Task {
                let result = await authCoordinator.authService.handleEmailConfirmation(url: url)
                
                await MainActor.run {
                    switch result {
                    case .success:
                        print("🎉 Email confirmation successful!")
                        // The auth state will be automatically updated by the AuthService
                    case .failure(let error):
                        print("❌ Email confirmation failed: \(error)")
                        // You might want to show an error alert here
                    }
                }
            }
        } else {
            print("ℹ️ Received non-auth deep link: \(url)")
        }
    }
}

#Preview {
    AuthView()
}
