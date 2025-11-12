//
//  CategoryDetailView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    @ObservedObject var dataManager: DataManager
    let initialCardIndex: Int
    @State private var currentCardIndex: Int
    @State private var showingSettings = false
    @State private var slideOffset: CGFloat = 0
    @State private var isTransitioning = false
    @Environment(\.presentationMode) var presentationMode
    
    init(category: Category, dataManager: DataManager, initialCardIndex: Int = 0) {
        self.category = category
        self.dataManager = dataManager
        self.initialCardIndex = initialCardIndex
        self._currentCardIndex = State(initialValue: initialCardIndex)
    }
    
    var filteredCards: [Flashcard] {
        if dataManager.userProgress.showOnlyUnlearned {
            return category.flashcards.filter { dataManager.getCardStatus($0.id) != .learned }
        }
        return category.flashcards
    }
    
    private func moveToNextCard() {
        if currentCardIndex < filteredCards.count - 1 {
            // Haptic feedback for card transition
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Slide out animation
            withAnimation(.easeInOut(duration: 0.2)) {
                slideOffset = -UIScreen.main.bounds.width
                isTransitioning = true
            }
            
            // After slide out, change card and slide in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentCardIndex += 1
                slideOffset = UIScreen.main.bounds.width
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    slideOffset = 0
                    isTransitioning = false
                }
            }
        } else {
            // We've reached the end - celebration haptic
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            // Could add visual celebration here in the future
        }
    }
    
    private func moveToPreviousCard() {
        if currentCardIndex > 0 {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Slide out animation
            withAnimation(.easeInOut(duration: 0.2)) {
                slideOffset = UIScreen.main.bounds.width
                isTransitioning = true
            }
            
            // After slide out, change card and slide in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentCardIndex -= 1
                slideOffset = -UIScreen.main.bounds.width
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    slideOffset = 0
                    isTransitioning = false
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .frame(height: 44)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(filteredCards.count) cards")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Settings")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .frame(width: 60, height: 44)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Progress indicator and controls
            HStack {
                // Progress indicator
                HStack(spacing: 8) {
                    Text("\(currentCardIndex + 1)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                    Text("of")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(filteredCards.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Show indicator if this is the last card
                    if currentCardIndex == filteredCards.count - 1 {
                        Text("•")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.green)
                            .opacity(0.8)
                    }
                }
                
                Spacer()
                
                // Toggle for showing only unlearned
                Button(action: {
                    dataManager.toggleShowOnlyUnlearned()
                    currentCardIndex = 0
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: dataManager.userProgress.showOnlyUnlearned ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text(dataManager.userProgress.showOnlyUnlearned ? "Show All" : "Unlearned Only")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            if filteredCards.isEmpty {
                VStack(spacing: 24) {
                    // Success animation
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                    
                    VStack(spacing: 12) {
                        Text("All cards learned!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Great job! You've learned all the words in this category.")
                            .font(.system(size: 16, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        dataManager.userProgress.showOnlyUnlearned = false
                        dataManager.saveProgress()
                        currentCardIndex = 0
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .medium))
                            Text("Show All Cards")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            } else {
                // Flashcard with slide animation
                FlashcardView(
                    flashcard: filteredCards[currentCardIndex],
                    dataManager: dataManager,
                    onStatusUpdated: {
                        moveToNextCard()
                    },
                    slideOffset: slideOffset,
                    isTransitioning: isTransitioning
                )
                
                // Navigation buttons
                HStack(spacing: 40) {
                    Button(action: {
                        moveToPreviousCard()
                    }) {
                    ZStack {
                        Circle()
                            .fill(currentCardIndex > 0 ? Color.blue.opacity(0.1) : Color(.systemGray5))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(currentCardIndex > 0 ? .blue : .gray)
                    }
                }
                .disabled(currentCardIndex == 0)
                .accessibilityLabel("Previous card")
                .accessibilityHint("Go to the previous flashcard")
                    
                    Button(action: {
                        if currentCardIndex < filteredCards.count - 1 {
                            moveToNextCard()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(currentCardIndex < filteredCards.count - 1 ? Color.blue.opacity(0.1) : Color(.systemGray5))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(currentCardIndex < filteredCards.count - 1 ? .blue : .gray)
                        }
                    }
                    .disabled(currentCardIndex == filteredCards.count - 1)
                    .accessibilityLabel("Next card")
                    .accessibilityHint("Go to the next flashcard")
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingSettings) {
            SettingsView(dataManager: dataManager)
        }
    }
} 