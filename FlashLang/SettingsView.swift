//
//  SettingsView.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "moon.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dark Mode")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Switch between light and dark themes")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { dataManager.userProgress.darkMode },
                            set: { _ in dataManager.toggleDarkMode() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .accessibilityLabel("Dark Mode")
                        .accessibilityHint("Toggles between light and dark appearance")
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Appearance")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .textCase(nil)
                        .padding(.bottom, 8)
                }
                
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Learning Progress")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Track your vocabulary mastery")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 8) {
                                Text("\(dataManager.getLearnedCardsCount())")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.green)
                                Text("Learned")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("\(dataManager.getFamiliarCardsCount())")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("Familiar")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 8) {
                                Text("\(dataManager.getNewCardsCount())")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.red)
                                Text("New")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reset All Progress")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                Text("Start fresh with all cards")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .textCase(nil)
                        .padding(.bottom, 8)
                }
                
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Version")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Current app version")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("German Vocabulary")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Learn essential German words")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .textCase(nil)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
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