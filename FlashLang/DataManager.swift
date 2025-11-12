//
//  DataManager.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var userProgress = UserProgress()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "userProgress"
    
    init() {
        loadProgress()
    }
    
    func loadProgress() {
        if let data = userDefaults.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        }
    }
    
    func saveProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            userDefaults.set(data, forKey: progressKey)
        }
    }
    
    func updateCardStatus(_ cardId: UUID, status: LearningStatus) {
        userProgress.cardStatuses[cardId] = status
        saveProgress()
    }
    
    func getCardStatus(_ cardId: UUID) -> LearningStatus {
        return userProgress.cardStatuses[cardId] ?? .new
    }
    
    func toggleShowOnlyUnlearned() {
        userProgress.showOnlyUnlearned.toggle()
        saveProgress()
    }
    
    func toggleDarkMode() {
        userProgress.darkMode.toggle()
        saveProgress()
    }
    
    func resetProgress() {
        userProgress.cardStatuses.removeAll()
        saveProgress()
    }
    
    func isCardLearned(_ cardId: UUID) -> Bool {
        return getCardStatus(cardId) == .learned
    }
    
    func getLearnedCardsCount() -> Int {
        return userProgress.cardStatuses.values.filter { $0 == .learned }.count
    }
    
    func getFamiliarCardsCount() -> Int {
        return userProgress.cardStatuses.values.filter { $0 == .familiar }.count
    }
    
    func getNewCardsCount() -> Int {
        return userProgress.cardStatuses.values.filter { $0 == .new }.count
    }
    
    func hasProgress() -> Bool {
        return getLearnedCardsCount() > 0 || getFamiliarCardsCount() > 0
    }
    
    // MARK: - Quiz Mode Methods
    
    func canUnlockQuizMode() -> Bool {
        let learnedCount = getLearnedCardsCount()
        let familiarCount = getFamiliarCardsCount()
        let total = learnedCount + familiarCount
        return total >= 15
    }
    
    func getQuizEligibleCards() -> [Flashcard] {
        var eligibleCards: [Flashcard] = []
        
        for category in Category.sampleCategories {
            for flashcard in category.flashcards {
                let status = getCardStatus(flashcard.id)
                if status == .learned || status == .familiar {
                    eligibleCards.append(flashcard)
                }
            }
        }
        
        return eligibleCards
    }
    
    func generateQuizQuestions(count: Int = 5) -> [QuizQuestion] {
        let eligibleCards = getQuizEligibleCards()
        guard eligibleCards.count >= 4 else { return [] } // Need at least 4 cards for multiple choice
        
        let shuffledCards = eligibleCards.shuffled()
        let selectedCards = Array(shuffledCards.prefix(min(count, eligibleCards.count)))
        
        var questions: [QuizQuestion] = []
        
        for card in selectedCards {
            // Get all other cards for wrong answers
            let otherCards = eligibleCards.filter { $0.id != card.id }
            let wrongAnswers = otherCards.shuffled().prefix(3).map { $0.english }
            
            // Create multiple choice options
            var options = wrongAnswers
            options.append(card.english) // Add correct answer
            options.shuffle() // Shuffle all options
            
            let question = QuizQuestion(
                id: UUID(),
                germanWord: card.german,
                correctAnswer: card.english,
                options: options,
                flashcard: card
            )
            
            questions.append(question)
        }
        
        return questions
    }
    
    func getTotalLearnedAndFamiliarCount() -> Int {
        return getLearnedCardsCount() + getFamiliarCardsCount()
    }
}

// MARK: - Quiz Models

struct QuizQuestion: Identifiable {
    let id: UUID
    let germanWord: String
    let correctAnswer: String
    let options: [String]
    let flashcard: Flashcard
}

struct QuizResult {
    let totalQuestions: Int
    let correctAnswers: Int
    let percentage: Double
    let timeTaken: TimeInterval
    
    var score: String {
        return "\(correctAnswers)/\(totalQuestions)"
    }
    
    var percentageString: String {
        return String(format: "%.0f%%", percentage)
    }
    
    var performanceMessage: String {
        switch percentage {
        case 90...100:
            return "Excellent! 🎉"
        case 80..<90:
            return "Great job! 👍"
        case 70..<80:
            return "Good work! 😊"
        case 60..<70:
            return "Not bad! 💪"
        default:
            return "Keep practicing! 📚"
        }
    }
} 