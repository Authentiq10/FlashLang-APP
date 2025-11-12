//
//  AuthTest.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import Foundation

// Simple test to verify Supabase authentication is working
class AuthTest {
    static func testSupabaseConnection() async {
        let authService = AuthService()
        authService.configure(
            supabaseUrl: "https://cyqugaekraiyuwgfejws.supabase.co",
            supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5cXVnYWVrcmFpeXV3Z2ZlandzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MTcwNzksImV4cCI6MjA3MDA5MzA3OX0.0FfjV0TZ6av0r2021rmF-RVcFMLBZaEeKRxhb6njJUc"
        )
        
        // Test signup with a test email
        let testEmail = "testuser\(Int.random(in: 1000...9999))@gmail.com"
        let testPassword = "TestPassword123!"
        
        print("🧪 Testing Supabase Authentication...")
        print("📧 Test Email: \(testEmail)")
        
        let signupResult = await authService.signUp(email: testEmail, fullName: "Test User", password: testPassword)
        
        switch signupResult {
        case .success(let user):
            print("✅ Signup successful!")
            print("👤 User ID: \(user.id)")
            print("📧 User Email: \(user.email)")
            
            // Test signin with the same credentials
            let signinResult = await authService.signIn(email: testEmail, password: testPassword)
            
            switch signinResult {
            case .success(let user):
                print("✅ Signin successful!")
                print("👤 User ID: \(user.id)")
                print("📧 User Email: \(user.email)")
                
                // Test signout
                await authService.signOut()
                print("✅ Signout successful!")
                
            case .failure(let error):
                print("❌ Signin failed: \(error.localizedDescription)")
            }
            
        case .failure(let error):
            print("❌ Signup failed: \(error.localizedDescription)")
            
            // If signup fails, try signin (user might already exist)
            print("🔄 Trying signin instead...")
            let signinResult = await authService.signIn(email: testEmail, password: testPassword)
            
            switch signinResult {
            case .success(let user):
                print("✅ Signin successful!")
                print("👤 User ID: \(user.id)")
                print("📧 User Email: \(user.email)")
                
                // Test signout
                await authService.signOut()
                print("✅ Signout successful!")
                
            case .failure(let error):
                print("❌ Signin also failed: \(error.localizedDescription)")
            }
        }
        
        print("🏁 Authentication test completed!")
    }
    
    // Simple test to verify the authentication flow without creating a new user
    static func testExistingUser() async {
        let authService = AuthService()
        authService.configure(
            supabaseUrl: "https://cyqugaekraiyuwgfejws.supabase.co",
            supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5cXVnYWVrcmFpeXV3Z2ZlandzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MTcwNzksImV4cCI6MjA3MDA5MzA3OX0.0FfjV0TZ6av0r2021rmF-RVcFMLBZaEeKRxhb6njJUc"
        )
        
        // Test with a known test user (you can replace with your own test credentials)
        let testEmail = "test@example.com"
        let testPassword = "password123"
        
        print("🧪 Testing Authentication with existing user...")
        print("📧 Test Email: \(testEmail)")
        
        let signinResult = await authService.signIn(email: testEmail, password: testPassword)
        
        switch signinResult {
        case .success(let user):
            print("✅ Signin successful!")
            print("👤 User ID: \(user.id)")
            print("📧 User Email: \(user.email)")
            
            // Test signout
            await authService.signOut()
            print("✅ Signout successful!")
            
        case .failure(let error):
            print("❌ Signin failed: \(error.localizedDescription)")
            print("💡 This is expected if the test user doesn't exist. You can create a test account in the app.")
        }
        
        print("🏁 Authentication test completed!")
    }
    
    // Test to verify Supabase project configuration
    static func testSupabaseProject() async {
        print("🔍 Testing Supabase Project Configuration...")
        
        let url = URL(string: "https://cyqugaekraiyuwgfejws.supabase.co/rest/v1/")!
        var request = URLRequest(url: url)
        request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5cXVnYWVrcmFpeXV3Z2ZlandzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MTcwNzksImV4cCI6MjA3MDA5MzA3OX0.0FfjV0TZ6av0r2021rmF-RVcFMLBZaEeKRxhb6njJUc", forHTTPHeaderField: "apikey")
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5cXVnYWVrcmFpeXV3Z2ZlandzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MTcwNzksImV4cCI6MjA3MDA5MzA3OX0.0FfjV0TZ6av0r2021rmF-RVcFMLBZaEeKRxhb6njJUc", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("✅ Supabase project is accessible!")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 Response: \(responseString)")
                    }
                } else {
                    print("❌ Supabase project returned status: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 Error Response: \(responseString)")
                    }
                }
            }
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
        }
        
        print("🏁 Project configuration test completed!")
    }
    
    // Manual test function that can be called from the app
    static func runManualTest() async {
        print("🚀 Starting Manual Authentication Test...")
        print("==================================================")
        
        // Test 1: Project configuration
        await testSupabaseProject()
        print("==================================================")
        
        // Test 2: Create a new user
        await testSupabaseConnection()
        print("==================================================")
        
        print("🏁 Manual test completed! Check the console for results.")
    }
} 