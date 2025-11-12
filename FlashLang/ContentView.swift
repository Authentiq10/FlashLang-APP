//
//  ContentView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @EnvironmentObject var authCoordinator: AuthCoordinator
    @State private var showingSettings = false
    @State private var showingSidebar = false
    @State private var showingProfile = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory: Category?
    @State private var selectedFlashcardIndex: Int = 0
    @State private var navigateToCategory = false
    @State private var showProgressAnimation = false
    @State private var showingQuiz = false
    
    // Computed properties for enhanced UI
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sun.max.fill"
        case 12..<17: return "sun.haze.fill"
        case 17..<22: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }
    
    private var greetingColors: [Color] {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: // Morning - Warm golden colors
            return [
                Color(red: 1.0, green: 0.8, blue: 0.4),    // Golden yellow
                Color(red: 1.0, green: 0.6, blue: 0.2)     // Warm orange
            ]
        case 12..<17: // Afternoon - Bright blue and cyan
            return [
                Color(red: 0.2, green: 0.7, blue: 1.0),    // Sky blue
                Color(red: 0.0, green: 0.8, blue: 0.9)     // Cyan
            ]
        case 17..<22: // Evening - Warm sunset colors
            return [
                Color(red: 1.0, green: 0.5, blue: 0.3),    // Sunset orange
                Color(red: 0.9, green: 0.3, blue: 0.4)     // Sunset pink
            ]
        default: // Night - Deep blue and indigo
            return [
                Color(red: 0.2, green: 0.3, blue: 0.7),    // Deep blue
                Color(red: 0.1, green: 0.2, blue: 0.5)     // Indigo
            ]
        }
    }
    
    private var userName: String {
        return authCoordinator.currentUser?.fullName ?? "Learner"
    }
    
    private var dailyMotivation: String {
        let totalProgress = dataManager.getLearnedCardsCount() + dataManager.getFamiliarCardsCount()
        
        if totalProgress == 0 {
            // New user with no progress
            return "Improve your vocabulary! 📚"
        } else {
            // User with progress
            let motivations = [
                "Keep improving your vocabulary! 🌟",
                "Every word learned is progress! 📚",
                "Keep improving your vocabulary! 🚀",
                "Learning German, one word at a time! 🇩🇪",
                "Your consistency is inspiring! ⭐"
            ]
            let index = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            return motivations[index % motivations.count]
        }
    }
    
    private var learningStreak: Int {
        // Mock data - in real app, this would come from UserDefaults or backend
        return 7
    }
    
    private var weeklyProgress: Int {
        return dataManager.getLearnedCardsCount() + dataManager.getFamiliarCardsCount()
    }
    
    private var weeklyProgressPercentage: Double {
        return min(Double(weeklyProgress) / 50.0 * 100.0, 100.0)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                ScrollView {
                VStack(spacing: 0) {
                        // Header with search and profile
                    HStack(spacing: 12) {
                        // Hamburger menu button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSidebar.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1),
                                            Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        
                        // Search bar
                        Button(action: {
                            isSearching = true
                        }) {
                                                HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                        
                        Text("Search a word...")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                            Color(red: 0.98, green: 0.96, blue: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.2), lineWidth: 1)
                    )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                            // Profile/avatar button
                        Button(action: {
                            showingProfile = true
                        }) {
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
                                .frame(width: 36, height: 36)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3), radius: 4, x: 0, y: 2)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                        .padding(.bottom, 20)
                    
                        // Greeting Section
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 12) {
                                        // Time-aware icon with animation
                                        Image(systemName: greetingIcon)
                                            .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                                    gradient: Gradient(colors: greetingColors),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .scaleEffect(showProgressAnimation ? 1.1 : 1.0)
                                            .animation(
                                                Animation.easeInOut(duration: 2.0)
                                                    .repeatForever(autoreverses: true),
                                                value: showProgressAnimation
                                            )
                                        
                                        Text(greetingMessage)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(colors: greetingColors),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    }
                                    
                                    Text(userName)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text(dailyMotivation)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                                
                                Spacer()
                                
                                // Learning streak
                                VStack(spacing: 4) {
                                    Text("🔥")
                                        .font(.system(size: 32))
                                    Text("\(learningStreak)")
                                            .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                    Text("day streak")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                            greetingColors[0].opacity(0.05),
                                            greetingColors[1].opacity(0.03)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                            greetingColors[0].opacity(0.2),
                                            greetingColors[1].opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        
                        // Quiz Mode Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Quiz Mode")
                                    .font(.system(size: 22, weight: .bold))
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
                                Spacer()
                                
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                            }
                            .padding(.horizontal, 20)
                            
                            if dataManager.canUnlockQuizMode() {
                                Button(action: {
                                    showingQuiz = true
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Take Quiz")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("Test your knowledge with 5 questions")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("Ready!")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.9))
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
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
                                    .cornerRadius(16)
                                    .shadow(color: Color(red: 0.2, green: 0.8, blue: 0.3).opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 16) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "book.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Start Learning First")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                            
                                            Text("Learn at least 15 words to unlock Quiz Mode")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    // Progress indicator
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text("Progress: \(dataManager.getTotalLearnedAndFamiliarCount())/15 words")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("\(Int(Double(dataManager.getTotalLearnedAndFamiliarCount()) / 8.0 * 100))%")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                        }
                                        
                                        // Progress bar
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(.systemGray5))
                                                    .frame(height: 8)
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                                                Color(red: 0.6, green: 0.4, blue: 0.9),
                                                                Color(red: 0.7, green: 0.5, blue: 1.0)
                                                            ]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: geometry.size.width * min(Double(dataManager.getTotalLearnedAndFamiliarCount()) / 15.0, 1.0), height: 8)
                                                    .animation(.easeInOut(duration: 0.5), value: dataManager.getTotalLearnedAndFamiliarCount())
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                }
                        .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 24)
                        
                        // Categories Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Study Categories")
                                    .font(.system(size: 22, weight: .bold))
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
                                Spacer()
                                
                                Text("\(Category.sampleCategories.count) categories")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                        
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(Category.sampleCategories) { category in
                                    NavigationLink(destination: CategoryDetailView(category: category, dataManager: dataManager, initialCardIndex: 0)) {
                                        CategoryCard(category: category, dataManager: dataManager)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
                .navigationBarHidden(true)
                
                // Sidebar overlay
                if showingSidebar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSidebar = false
                            }
                        }
                }
                
                // Sidebar
                HStack {
                    SidebarView(dataManager: dataManager, showingSidebar: $showingSidebar, authCoordinator: authCoordinator)
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .background(Color(.systemBackground))
                        .offset(x: showingSidebar ? 0 : -UIScreen.main.bounds.width * 0.75)
                        .animation(.easeInOut(duration: 0.3), value: showingSidebar)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(dataManager: dataManager, authCoordinator: authCoordinator)
        }
        .fullScreenCover(isPresented: $showingQuiz) {
            QuizView()
                .environmentObject(dataManager)
        }
        .sheet(isPresented: $isSearching) {
            SearchView(dataManager: dataManager, searchText: $searchText) { flashcard in
                // Handle navigation to specific flashcard
                if let category = findCategoryForFlashcard(flashcard) {
                    navigateToFlashcard(flashcard, in: category)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.92, blue: 1.0),
                    Color(red: 0.98, green: 0.96, blue: 1.0),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .preferredColorScheme(dataManager.userProgress.darkMode ? .dark : .light)
        .onAppear {
            // Trigger progress animation when view appears
            if dataManager.hasProgress() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showProgressAnimation = true
                    }
                }
            }
            
            // Trigger greeting icon animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showProgressAnimation = true
            }
        }
        .onChange(of: dataManager.hasProgress()) { oldValue, hasProgress in
            // Trigger animation when progress changes (user returns from learning)
            if hasProgress {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showProgressAnimation = true
                    }
                }
            } else {
                showProgressAnimation = false
            }
        }
        .navigationDestination(isPresented: $navigateToCategory) {
            if let category = selectedCategory {
                CategoryDetailView(
                    category: category,
                    dataManager: dataManager,
                    initialCardIndex: selectedFlashcardIndex
                )
            }
        }
        .onChange(of: navigateToCategory) { oldValue, newValue in
            if !newValue {
                // Reset selection when navigation is complete
                selectedCategory = nil
                selectedFlashcardIndex = 0
            }
        }
    }
    
    private func findCategoryForFlashcard(_ flashcard: Flashcard) -> Category? {
        return Category.sampleCategories.first { category in
            category.flashcards.contains { $0.id == flashcard.id }
        }
    }
    
    private func navigateToFlashcard(_ flashcard: Flashcard, in category: Category) {
        // Find the index of the flashcard in the category
        if let flashcardIndex = category.flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            selectedCategory = category
            selectedFlashcardIndex = flashcardIndex
            navigateToCategory = true
        }
        
        // Close the search view
        isSearching = false
    }
}

struct CategoryCard: View {
    let category: Category
    @ObservedObject var dataManager: DataManager
    
    var learnedCount: Int {
        category.flashcards.filter { dataManager.getCardStatus($0.id) == .learned }.count
    }
    
    var familiarCount: Int {
        category.flashcards.filter { dataManager.getCardStatus($0.id) == .familiar }.count
    }
    
    var totalProgress: Int {
        learnedCount + familiarCount
    }
    
    var progressPercentage: Double {
        Double(totalProgress) / Double(category.flashcards.count)
    }
    
    var hasProgress: Bool {
        totalProgress > 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon and title section
        VStack(spacing: 12) {
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
                    .frame(width: 60, height: 60)
                        .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(category.name)
                .font(.system(size: 18, weight: .bold))
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
                .multilineTextAlignment(.center)
            }
            
            // Progress section
            VStack(spacing: 8) {
                HStack {
                    Text("\(category.flashcards.count) words")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
            if hasProgress {
                        Text("\(totalProgress) studied")
                        .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    }
                }
                    
                if hasProgress {
                    GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.92, green: 0.92, blue: 0.96))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.8, blue: 0.3),
                                            Color(red: 0.3, green: 0.9, blue: 0.4)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                                .frame(width: geometry.size.width * progressPercentage, height: 6)
                                .animation(.easeInOut(duration: 0.6), value: progressPercentage)
                    }
                }
                    .frame(height: 6)
            } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.92, green: 0.92, blue: 0.96))
                        .frame(height: 6)
                }
            }
        }
        .padding(20)
        .frame(height: 180)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(red: 0.98, green: 0.96, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.2),
                            Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct SearchView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var searchText: String
    let onFlashcardSelected: (Flashcard) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var searchResults: [Flashcard] {
        guard !searchText.isEmpty else { return [] }
        
        return Category.sampleCategories.flatMap { category in
            category.flashcards.filter { flashcard in
                flashcard.english.localizedCaseInsensitiveContains(searchText) ||
                flashcard.german.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                
                if searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Search for German or English words")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Type in the search field above to find flashcards")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No results found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Try searching for a different word")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults) { flashcard in
                        Button(action: {
                            onFlashcardSelected(flashcard)
                        }) {
                            FlashcardRowView(flashcard: flashcard, dataManager: dataManager)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FlashcardRowView: View {
    let flashcard: Flashcard
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                                        Text(flashcard.german)
                        .font(.headline)
                                            .foregroundColor(.primary)
                    
                    Text(flashcard.english)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                StatusBadge(status: dataManager.getCardStatus(flashcard.id))
            }
                                    
                                    Text(flashcard.exampleSentence)
                .font(.caption)
                                        .foregroundColor(.secondary)
                                        .italic()
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: LearningStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
                                        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(status.color).opacity(0.2))
        .foregroundColor(Color(status.color))
                                        .cornerRadius(8)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search words...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct ProfileView: View {
    @ObservedObject var dataManager: DataManager
    let authCoordinator: AuthCoordinator
    @Environment(\.presentationMode) var presentationMode
    
    private var joinedDate: String {
        guard let createdAt = authCoordinator.currentUser?.createdAt else { return "Unknown" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        
        // Fallback to simple format if ISO8601 parsing fails
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = fallbackFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        
        return createdAt
    }
    
    private var userInitials: String {
        guard let fullName = authCoordinator.currentUser?.fullName, !fullName.isEmpty else { return "U" }
        
        let names = fullName.split(separator: " ")
        if names.count >= 2 {
            let firstInitial = String(names[0].prefix(1)).uppercased()
            let lastInitial = String(names[1].prefix(1)).uppercased()
            return firstInitial + lastInitial
        } else if let firstInitial = names.first?.prefix(1) {
            return String(firstInitial).uppercased()
        }
        return "U"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 0) {
                    // Header Section
                VStack(spacing: 20) {
                        // Profile Avatar
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
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3), radius: 12, x: 0, y: 6)
                            
                            Text(userInitials)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        // User Name
                        VStack(spacing: 4) {
                            Text(authCoordinator.currentUser?.fullName ?? "User")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
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
                                .multilineTextAlignment(.center)
                            
                            Text("FlashLang Learner")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    // User Information Cards
                    VStack(spacing: 16) {
                        // Account Information Section
                        VStack(spacing: 12) {
                    HStack {
                                Text("Account Information")
                                    .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                            .padding(.horizontal, 24)
                    
                    VStack(spacing: 0) {
                                ProfileInfoRow(
                                    icon: "envelope.fill",
                                    iconColor: .blue,
                                    title: "Email Address",
                                    value: authCoordinator.currentUser?.email ?? "Not available",
                                    isFirst: true
                                )
                                
                                ProfileInfoRow(
                                    icon: "person.fill",
                                    iconColor: .green,
                                    title: "Full Name",
                                    value: authCoordinator.currentUser?.fullName ?? "Not available",
                                    isFirst: false
                                )
                                
                                ProfileInfoRow(
                                    icon: "number",
                                    iconColor: .orange,
                                    title: "User ID",
                                    value: authCoordinator.currentUser?.id ?? "Not available",
                                    isFirst: false
                                )
                                
                                ProfileInfoRow(
                                    icon: "calendar",
                                    iconColor: .purple,
                                    title: "Member Since",
                                    value: joinedDate,
                                    isLast: true
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                        .padding(.horizontal, 20)
                        }
                        
                        // Learning Statistics Section
                        VStack(spacing: 12) {
                            HStack {
                                Text("Learning Progress")
                                    .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                ProfileStatsRow(
                                    icon: "checkmark.circle.fill",
                                    iconColor: .green,
                                    title: "Words Learned",
                                    value: "\(dataManager.getLearnedCardsCount())",
                                    isFirst: true
                                )
                                
                                ProfileStatsRow(
                                    icon: "brain.head.profile",
                                    iconColor: .orange,
                                    title: "Words Familiar",
                                    value: "\(dataManager.getFamiliarCardsCount())",
                                    isFirst: false
                                )
                                
                                ProfileStatsRow(
                                    icon: "book.fill",
                                    iconColor: .blue,
                                    title: "Total Categories",
                                    value: "\(Category.sampleCategories.count)",
                                    isFirst: false
                                )
                                
                                ProfileStatsRow(
                                    icon: "percent",
                                    iconColor: .purple,
                                    title: "Overall Progress",
                                    value: "\(calculateOverallProgress())%",
                                    isLast: true
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                        .padding(.horizontal, 20)
                        }
                }
                .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.92, blue: 1.0),
                        Color(red: 0.98, green: 0.96, blue: 1.0),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func calculateOverallProgress() -> Int {
        let totalCards = Category.sampleCategories.flatMap { $0.flashcards }.count
        let learnedCards = dataManager.getLearnedCardsCount() + dataManager.getFamiliarCardsCount()
        
        guard totalCards > 0 else { return 0 }
        return Int((Double(learnedCards) / Double(totalCards)) * 100)
    }
}

// MARK: - Profile Components

struct ProfileInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                }
                
                                       Spacer()
                                   }
                                   .padding(.horizontal, 20)
                                   .padding(.vertical, 16)

            if !isLast {
                Divider()
                    .padding(.leading, 72)
            }
        }
    }
}

struct ProfileStatsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
                                   VStack(spacing: 0) {
                                       HStack(spacing: 16) {
                                           ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                                           Spacer()

                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(iconColor)
                                       }
                                       .padding(.horizontal, 20)
                                       .padding(.vertical, 16)
            
            if !isLast {
                Divider()
                    .padding(.leading, 72)
            }
        }
    }
}

struct SidebarView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var showingSidebar: Bool
    let authCoordinator: AuthCoordinator
    @State private var showResetAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Header with App Branding
                               VStack(spacing: 0) {
                                   HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FlashLang")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                           .foregroundStyle(
                                               LinearGradient(
                                                   gradient: Gradient(colors: [
                                        Color(red: 0.5, green: 0.3, blue: 0.9),
                                        Color(red: 0.7, green: 0.4, blue: 0.9)
                                                   ]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing
                                               )
                                           )
                        
                        Text("German Vocabulary Learning")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                                   }

                    Spacer()
                    
                                       Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSidebar = false
                        }
                                       }) {
                                               ZStack {
                                                   Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .background(Color(.systemGray4))
            }
            .background(Color(.systemBackground))
            
            // Content List
            List {
                // Appearance Section
                Section {
                    SettingsRow(
                        icon: "moon.fill",
                        iconColor: .indigo,
                        title: "Dark Mode",
                        subtitle: "Switch between light and dark themes"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { dataManager.userProgress.darkMode },
                            set: { _ in dataManager.toggleDarkMode() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .indigo))
                    }
                } header: {
                    Text("Appearance")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                
                // Data Section
                Section {
                    SettingsActionRow(
                        icon: "arrow.clockwise",
                        iconColor: .red,
                        title: "Reset All Progress",
                        subtitle: "Start fresh with all cards",
                        action: { showResetAlert = true }
                    )
                } header: {
                    Text("Data")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                        
                                                       // About Section
                Section {
                    SettingsInfoRow(
                        icon: "info.circle.fill",
                        iconColor: .blue,
                        title: "Version",
                        subtitle: "Current app version",
                        value: "1.0.0"
                    )
                } header: {
                    Text("About")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                
                // Account Section
                Section {
                    SettingsActionRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        iconColor: .red,
                        title: "Sign Out",
                        subtitle: "Log out of your account",
                        action: {
                            Task {
                                await authCoordinator.signOut()
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSidebar = false
                            }
                        }
                    )
                } header: {
                    Text("Account")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
            }
            .listStyle(PlainListStyle())
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataManager.resetProgress()
            }
        } message: {
            Text("This will reset all your learned cards. This action cannot be undone.")
        }
    }
}

// MARK: - Custom Settings Components

struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let content: Content
    
    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
                                       HStack(spacing: 16) {
                                           ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

                                           Spacer()
            
            content
        }
        .padding(.vertical, 2)
    }
}

struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
                           HStack(spacing: 16) {
                               ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                               Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    
    var body: some View {
                           HStack(spacing: 16) {
                               ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}