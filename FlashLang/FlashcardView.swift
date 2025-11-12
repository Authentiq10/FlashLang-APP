//
//  FlashcardView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI
import AVFoundation

struct FlashcardView: View {
    let flashcard: Flashcard
    @State private var cardState: CardState = .german
    @State private var pressedStatus: LearningStatus? = nil
    @State private var isPlayingAudio = false
    @State private var flipDegrees: Double = 0
    @ObservedObject var dataManager: DataManager
    let onStatusUpdated: (() -> Void)?
    let slideOffset: CGFloat
    let isTransitioning: Bool
    
    // Speech synthesizer for pronunciation
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    enum CardState {
        case german
        case english
    }
    
    init(flashcard: Flashcard, dataManager: DataManager, onStatusUpdated: (() -> Void)? = nil, slideOffset: CGFloat = 0, isTransitioning: Bool = false) {
        self.flashcard = flashcard
        self.dataManager = dataManager
        self.onStatusUpdated = onStatusUpdated
        self.slideOffset = slideOffset
        self.isTransitioning = isTransitioning
    }
    
    private func resetCardState() {
        cardState = .german
        pressedStatus = nil
        flipDegrees = 0
    }
    
    private func playAudio() {
        // Stop any currently playing audio
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Create speech utterance
        let utterance = AVSpeechUtterance(string: flashcard.german)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE") // German voice
        utterance.rate = 0.5 // Slower rate for better pronunciation
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        
        // Set playing state
        isPlayingAudio = true
        
        // Play the audio
        speechSynthesizer.speak(utterance)
        
        // Reset playing state when finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPlayingAudio = false
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func nextCardState() {
        // Haptic feedback for card flip
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Toggle card state immediately
        cardState = cardState == .german ? .english : .german
        
        // Animate the flip
        withAnimation(.easeInOut(duration: 0.4)) {
            flipDegrees += 180
        }
        
        // Reset flip degrees after animation to prevent overflow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if flipDegrees >= 360 {
                flipDegrees = 0
            }
        }
    }
    
    private func getStatusColor(_ status: LearningStatus) -> Color {
        switch status {
        case .new: return Color(red: 0.9, green: 0.3, blue: 0.3) // Softer red
        case .familiar: return Color(red: 1.0, green: 0.6, blue: 0.2) // Softer orange
        case .learned: return Color(red: 0.3, green: 0.8, blue: 0.4) // Softer green
        }
    }
    
    private func getStatusBackground(_ status: LearningStatus) -> Color {
        switch status {
        case .new: return Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.1)
        case .familiar: return Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1)
        case .learned: return Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.1)
        }
    }
    
    private var cardFront: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .overlay(
                VStack(spacing: 16) {
                    // Language indicator badge
                    HStack {
                        Spacer()
                        Text("German")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.6, green: 0.4, blue: 0.9))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: 16) {
                        Text(flashcard.german)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        
                        // Audio button
                        Button(action: playAudio) {
                            HStack(spacing: 8) {
                                Image(systemName: isPlayingAudio ? "speaker.wave.2.fill" : "speaker.wave.2")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Listen")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.4, blue: 0.9), // Purple
                                        Color(red: 0.7, green: 0.5, blue: 1.0)  // Light purple
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3), radius: 4, x: 0, y: 2)
                            .scaleEffect(isPlayingAudio ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isPlayingAudio)
                        }
                        .disabled(isPlayingAudio)
                    }
                    
                    Spacer()
                    
                    // Example button
                    Button(action: {
                        // Stop any currently playing audio
                        speechSynthesizer.stopSpeaking(at: .immediate)
                        
                        // Create speech utterance for example sentence
                        let utterance = AVSpeechUtterance(string: flashcard.exampleSentence)
                        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
                        utterance.rate = 0.4 // Even slower for sentences
                        utterance.pitchMultiplier = 1.0
                        utterance.volume = 0.8
                        
                        // Set playing state
                        isPlayingAudio = true
                        
                        // Play the audio
                        speechSynthesizer.speak(utterance)
                        
                        // Reset playing state when finished
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            isPlayingAudio = false
                        }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Example")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.9, green: 0.6, blue: 0.2), // Orange
                                    Color(red: 1.0, green: 0.7, blue: 0.3)  // Light orange
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.9, green: 0.6, blue: 0.2).opacity(0.3), radius: 4, x: 0, y: 2)
                        .scaleEffect(isPlayingAudio ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isPlayingAudio)
                    }
                    .disabled(isPlayingAudio)
                    
                    // Tap indicator
                    HStack {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                        Text("Tap to flip")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(24)
            )
    }
    
    private var cardBack: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .overlay(
                VStack(spacing: 16) {
                    // Language indicator badge
                    HStack {
                        Spacer()
                        Text("English")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.3, green: 0.7, blue: 0.9)) // Blue for English
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Main word
                    Text(flashcard.english)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    // Example button
                    Button(action: {
                        // Stop any currently playing audio
                        speechSynthesizer.stopSpeaking(at: .immediate)
                        
                        // Create speech utterance for example sentence
                        let utterance = AVSpeechUtterance(string: flashcard.exampleSentence)
                        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
                        utterance.rate = 0.4 // Even slower for sentences
                        utterance.pitchMultiplier = 1.0
                        utterance.volume = 0.8
                        
                        // Set playing state
                        isPlayingAudio = true
                        
                        // Play the audio
                        speechSynthesizer.speak(utterance)
                        
                        // Reset playing state when finished
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            isPlayingAudio = false
                        }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Example")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.9, green: 0.6, blue: 0.2), // Orange
                                    Color(red: 1.0, green: 0.7, blue: 0.3)  // Light orange
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.9, green: 0.6, blue: 0.2).opacity(0.3), radius: 4, x: 0, y: 2)
                        .scaleEffect(isPlayingAudio ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isPlayingAudio)
                    }
                    .disabled(isPlayingAudio)
                    
                    // Tap indicator
                    HStack {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                        Text("Tap to flip back")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.7, blue: 0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(24)
            )
    }
    
    private func statusButton(for status: LearningStatus) -> some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            if status == .learned {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                dataManager.updateCardStatus(flashcard.id, status: status)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onStatusUpdated?()
            }
        }) {
            VStack(spacing: 8) {
                // Circular icon background
                ZStack {
                    Circle()
                        .fill(pressedStatus == status ? getStatusColor(status).opacity(0.2) : Color.white)
                        .frame(width: 48, height: 48)
                        .shadow(color: getStatusColor(status).opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: status.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(getStatusColor(status))
                }
                
                Text(status.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: pressedStatus == status ? getStatusColor(status).opacity(0.2) : Color.black.opacity(0.05), radius: pressedStatus == status ? 6 : 3, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(getStatusColor(status).opacity(pressedStatus == status ? 0.4 : 0.2), lineWidth: pressedStatus == status ? 2 : 1)
            )
        }
        .buttonStyle(LearningStatusButtonStyle(status: status, isSelected: pressedStatus == status))
        .scaleEffect(pressedStatus == status ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: pressedStatus)
        .accessibilityLabel("Mark as \(status.displayName.lowercased())")
        .accessibilityHint("Marks this word as \(status.displayName.lowercased()) and moves to next card")
        .accessibilityAddTraits(.isButton)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { isPressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                pressedStatus = isPressing ? status : nil
            }
        }, perform: {})
    }
    
    private var statusButtonsRow: some View {
        HStack(spacing: 12) {
            ForEach(LearningStatus.allCases, id: \.self) { status in
                statusButton(for: status)
            }
        }
    }
    
    private var learningStatusButtons: some View {
        VStack(spacing: 16) {
            Text("How well do you know this word?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .multilineTextAlignment(.center)
            
            statusButtonsRow
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Main card container with slide and flip animations
            ZStack {
                // Front side (German)
                cardFront
                    .opacity(cardState == .german ? 1 : 0)
                
                // Back side (English)
                cardBack
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(cardState == .english ? 1 : 0)
            }
            .frame(height: 220)
            .offset(x: slideOffset)
            .opacity(isTransitioning ? 0.8 : 1.0)
            .rotation3DEffect(
                .degrees(flipDegrees),
                axis: (x: 0, y: 1, z: 0)
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 8 + (flipDegrees.truncatingRemainder(dividingBy: 180) / 180) * 4,
                x: 0,
                y: 4 + (flipDegrees.truncatingRemainder(dividingBy: 180) / 180) * 2
            )
            .onTapGesture {
                nextCardState()
            }
            .accessibilityLabel("Flashcard showing \(cardState == .german ? "German word" : "English translation")")
            .accessibilityHint("Tap to \(cardState == .german ? "see English translation" : "see German word")")
            .accessibilityAddTraits(.allowsDirectInteraction)
            .onChange(of: flashcard.id) { oldValue, newValue in
                resetCardState()
            }
            
            // Learning status section - always visible
            VStack(spacing: 20) {
                learningStatusButtons
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.96, blue: 1.0), // Very light purple
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .animation(.easeInOut(duration: 0.3), value: cardState)
    }
}

struct LearningStatusButtonStyle: ButtonStyle {
    let status: LearningStatus
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}