//
//  SpiritualGuideChatView.swift
//  Glass Window
//
//  Created by mac on 21/10/2026.
//

import SwiftUI
import CoreML

public struct SpiritualGuideChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router
    @StateObject private var llmManager = CoreMLLLMManager.shared
    
    @State private var inputText: String = ""
    @State private var copiedMessageId: UUID? = nil
    @State private var savedPrayerIds: Set<UUID> = []
    
    // Quick Prompt Suggestions
    private let suggestionPills = [
        "💡 What is AI?",
        "🕊️ Prayer for Peace & Calm",
        "📖 Explain Today's Gospel",
        "❤️ Finding Forgiveness",
        "🌙 Night Examen & Gratitude",
        "🧭 Guidance for Decisions"
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Refractive Atmospheric Background
            LiquidAtmosphereBackground()
            
            VStack(spacing: 0) {
                // Top Glass Navigation Bar
                headerView
                
                // Messages & Suggestions ScrollView
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Suggestion Pills Carousel
                            suggestionsScrollView
                            
                            // Chat Messages Stream
                            ForEach(llmManager.messages) { message in
                                messageRow(message)
                                    .id(message.id)
                            }
                            
                            // Bottom padding
                            Color.clear.frame(height: 16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                    .safeAreaInset(edge: .bottom) {
                        inputBarView
                    }
                    .onChange(of: llmManager.messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: llmManager.messages.last?.content) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            llmManager.stopSpeaking()
        }
    }
    
    // MARK: - 1. Top Glass Header
    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            // Dismiss Button
            Button {
                llmManager.stopSpeaking()
                dismiss()
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            
            // Title & Neural Engine Badge
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Spiritual Guide")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 5, height: 5)
                    
                    Text(llmManager.modelStatusText)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.70))
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // New Chat / Reset Button
                if llmManager.messages.count > 1 {
                    Button {
                        withAnimation {
                            llmManager.resetConversation()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 11, weight: .bold))
                            Text("New")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color.white.opacity(0.85))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                // Close / Done Pill
                Button {
                    llmManager.stopSpeaking()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            Color.black.opacity(0.35)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        )
    }
    
    // MARK: - 2. Suggestions Scroll View
    private var suggestionsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestionPills, id: \.self) { pill in
                    Button {
                        let cleanPrompt = pill.components(separatedBy: " ").dropFirst().joined(separator: " ")
                        inputText = ""
                        llmManager.sendMessage(cleanPrompt)
                    } label: {
                        Text(pill)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.12), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - 3. Message Row
    @ViewBuilder
    private func messageRow(_ message: ChatMessage) -> some View {
        if message.isUser {
            userMessageBubble(message)
        } else {
            assistantMessageCard(message)
        }
    }
    
    // User Bubble
    private func userMessageBubble(_ message: ChatMessage) -> some View {
        HStack {
            Spacer(minLength: 40)
            
            Text(message.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.45, blue: 0.52),
                            Color(red: 0.12, green: 0.28, blue: 0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.8)
                )
        }
    }
    
    // Assistant Card with Liquid Glass & Actions
    private func assistantMessageCard(_ message: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Avatar & Scripture Citation
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.82, blue: 0.45),
                                    Color(red: 0.75, green: 0.55, blue: 0.20)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.85))
                }
                
                Text("AI Assistant")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.95))
                
                Spacer()
                
                if let citation = message.scriptureCitation {
                    Text(citation)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3.5)
                        .background(Color(red: 0.95, green: 0.82, blue: 0.45).opacity(0.15), in: Capsule())
                }
            }
            
            // Content Text with Markdown Rendering
            Text(LocalizedStringKey(message.content.isEmpty ? "..." : message.content))
                .font(.system(size: 14, weight: .regular, design: .serif))
                .lineSpacing(4)
                .foregroundStyle(Color.white.opacity(0.95))
                .textSelection(.enabled)
            
            // Action Buttons Row (Listen Aloud, Save, Copy)
            if !message.isStreaming && !message.content.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.12))
                    .padding(.vertical, 2)
                
                HStack(spacing: 12) {
                    // 1. Listen Aloud Button
                    Button {
                        llmManager.speak(messageId: message.id, text: message.content)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: (llmManager.isSpeaking && llmManager.currentlySpeakingId == message.id) ? "stop.circle.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 12))
                            Text((llmManager.isSpeaking && llmManager.currentlySpeakingId == message.id) ? "Stop" : "Listen Aloud")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.08), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // 2. Save Prayer Button (Only for prayer / faith content)
                    if message.scriptureCitation != nil || message.content.lowercased().contains("amen") || message.content.lowercased().contains("lord") {
                        Button {
                            savedPrayerIds.insert(message.id)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: savedPrayerIds.contains(message.id) ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 12))
                                Text(savedPrayerIds.contains(message.id) ? "Saved" : "Save Prayer")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(Color.white.opacity(0.80))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.08), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    // 3. Copy Button
                    Button {
                        UIPasteboard.general.string = message.content
                        copiedMessageId = message.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if copiedMessageId == message.id {
                                copiedMessageId = nil
                            }
                        }
                    } label: {
                        Image(systemName: copiedMessageId == message.id ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.70))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 20)
    }
    
    // MARK: - 4. Floating Input Bar
    private var inputBarView: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.45).opacity(0.85))
                
                TextField("Ask anything (AI, science, scripture, prayer)...", text: $inputText, axis: .vertical)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white)
                    .lineLimit(1...4)
                
                if !inputText.isEmpty {
                    Button {
                        inputText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .liquidGlass(cornerRadius: 24)
            
            // Send Button
            Button {
                let prompt = inputText
                inputText = ""
                llmManager.sendMessage(prompt)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            Color.white.opacity(0.15) :
                            Color(red: 0.95, green: 0.82, blue: 0.45)
                        )
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            Color.white.opacity(0.4) :
                            Color.black.opacity(0.85)
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Helpers
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastId = llmManager.messages.last?.id {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}
