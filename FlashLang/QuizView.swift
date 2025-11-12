//
//  QuizView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var isAnswerSelected = false
    @State private var correctAnswers = 0
    @State private var showingResults = false
    @State private var quizStartTime = Date()
    @State private var showingQuiz = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            if showingResults {
                QuizResultsView(
                    result: QuizResult(
                        totalQuestions: questions.count,
                        correctAnswers: correctAnswers,
                        percentage: Double(correctAnswers) / Double(questions.count) * 100,
                        timeTaken: Date().timeIntervalSince(quizStartTime)
                    )
                ) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else if showingQuiz {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Progress indicator
                        HStack(spacing: 8) {
                            ForEach(0..<questions.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentQuestionIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Spacer()
                        
                        // Question counter
                        Text("\(currentQuestionIndex + 1)/\(questions.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Question
                    VStack(spacing: 20) {
                        Text("What does this German word mean?")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Text(currentQuestion.germanWord)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(currentQuestion.options, id: \.self) { option in
                            AnswerButton(
                                text: option,
                                isSelected: selectedAnswer == option,
                                isCorrect: isAnswerSelected && option == currentQuestion.correctAnswer,
                                isWrong: isAnswerSelected && selectedAnswer == option && option != currentQuestion.correctAnswer
                            ) {
                                selectAnswer(option)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Preparing your quiz...")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            startQuiz()
        }
    }
    
    private var currentQuestion: QuizQuestion {
        guard currentQuestionIndex < questions.count else {
            return questions.first ?? QuizQuestion(
                id: UUID(),
                germanWord: "",
                correctAnswer: "",
                options: [],
                flashcard: Flashcard(english: "", german: "", exampleSentence: "")
            )
        }
        return questions[currentQuestionIndex]
    }
    
    private func startQuiz() {
        questions = dataManager.generateQuizQuestions(count: 5)
        quizStartTime = Date()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingQuiz = true
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        guard !isAnswerSelected else { return }
        
        selectedAnswer = answer
        isAnswerSelected = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Check if answer is correct
        if answer == currentQuestion.correctAnswer {
            correctAnswers += 1
            
            // Success haptic
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        } else {
            // Error haptic
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
        }
        
        // Move to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            moveToNextQuestion()
        }
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
                selectedAnswer = nil
                isAnswerSelected = false
            }
        } else {
            // Quiz completed
            withAnimation(.easeInOut(duration: 0.5)) {
                showingResults = true
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(buttonTextColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(buttonBorderColor, lineWidth: 2)
                    )
            )
        }
        .disabled(isSelected)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var buttonBackgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isWrong {
            return Color.red.opacity(0.2)
        } else if isSelected {
            return Color.white.opacity(0.3)
        } else {
            return Color.white.opacity(0.1)
        }
    }
    
    private var buttonBorderColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color.white.opacity(0.5)
        } else {
            return Color.white.opacity(0.2)
        }
    }
    
    private var buttonTextColor: Color {
        if isCorrect || isWrong {
            return .white
        } else {
            return .white
        }
    }
}

struct QuizResultsView: View {
    let result: QuizResult
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Result icon
            Image(systemName: resultIcon)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            // Performance message
            Text(result.performanceMessage)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Score details
            VStack(spacing: 15) {
                Text(result.score)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text(result.percentageString)
                    .font(.title)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Time: \(formatTime(result.timeTaken))")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: {
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Back to Home")
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
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var resultIcon: String {
        switch result.percentage {
        case 90...100:
            return "star.circle.fill"
        case 80..<90:
            return "hand.thumbsup.circle.fill"
        case 70..<80:
            return "face.smiling.circle.fill"
        case 60..<70:
            return "heart.circle.fill"
        default:
            return "book.circle.fill"
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

#Preview {
    QuizView()
        .environmentObject(DataManager())
}
