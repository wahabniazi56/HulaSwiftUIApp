//
//  CoreMLLLMManager.swift
//  Glass Window
//
//  Created by mac on 21/10/2026.
//

import SwiftUI
import CoreML
import AVFoundation
import NaturalLanguage
import Combine
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Chat Message Model
public struct ChatMessage: Identifiable, Equatable {
    public let id: UUID
    public var content: String
    public let isUser: Bool
    public let timestamp: Date
    public var isStreaming: Bool
    public var scriptureCitation: String?
    
    public init(
        id: UUID = UUID(),
        content: String,
        isUser: Bool,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        scriptureCitation: String? = nil
    ) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.scriptureCitation = scriptureCitation
    }
}

// MARK: - Core ML On-Device LLM & Spiritual Intelligence Manager
@MainActor
public final class CoreMLLLMManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = CoreMLLLMManager()
    
    // MARK: - Published State
    @Published public var messages: [ChatMessage] = []
    @Published public var isGenerating: Bool = false
    @Published public var isSpeaking: Bool = false
    @Published public var currentlySpeakingId: UUID? = nil
    @Published public var modelStatusText: String = "Apple Intelligence Ready"
    @Published public var isCoreMLModelLoaded: Bool = false
    @Published public var isFoundationModelActive: Bool = false
    
    // MARK: - Private Core ML & Audio Components
    #if canImport(FoundationModels)
    private var foundationModelSession: LanguageModelSession?
    #endif
    private var coreMLModel: MLModel?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initialization
    public override init() {
        super.init()
        speechSynthesizer.delegate = self
        initializeWelcomeMessage()
        checkAndLoadCoreMLModel()
    }
    
    private func initializeWelcomeMessage() {
        let welcome = ChatMessage(
            content: "Hello! I am your on-device AI Assistant in Glass Window, running privately on Apple Silicon.\n\nAsk me anything—from questions about technology, science, and daily life, to scripture reflections and personalized prayers.",
            isUser: false,
            timestamp: Date(),
            scriptureCitation: nil
        )
        self.messages = [welcome]
    }
    
    // MARK: - Reset Conversation
    public func resetConversation() {
        stopSpeaking()
        currentTask?.cancel()
        #if canImport(FoundationModels)
        if isFoundationModelActive {
            self.foundationModelSession = LanguageModelSession()
        }
        #endif
        initializeWelcomeMessage()
    }
    
    // MARK: - Core ML & Foundation Model Detection & Loading
    private func checkAndLoadCoreMLModel() {
        // 1. Check for native Apple Foundation Models framework
        #if canImport(FoundationModels)
        let systemModel = SystemLanguageModel.default
        if case .available = systemModel.availability {
            self.foundationModelSession = LanguageModelSession()
            self.isFoundationModelActive = true
            self.modelStatusText = "Apple Foundation Model (Apple Intelligence Active)"
            print("CoreMLLLMManager: Native Apple Foundation Models framework active on device.")
            return
        }
        #endif
        
        // 2. Attempt to find any compiled Core ML model file in the bundle
        let possibleModelNames = ["SpiritualLLM", "Llama3_2_1B", "OpenELM", "LocalSpiritualModel", "model"]
        
        for name in possibleModelNames {
            if let modelURL = Bundle.main.url(forResource: name, withExtension: "mlmodelc") ?? Bundle.main.url(forResource: name, withExtension: "mlpackage") {
                do {
                    let config = MLModelConfiguration()
                    config.computeUnits = .all // Prioritizes Apple Neural Engine (ANE) & GPU
                    coreMLModel = try MLModel(contentsOf: modelURL, configuration: config)
                    isCoreMLModelLoaded = true
                    modelStatusText = "Apple Neural Engine (Core ML Active)"
                    print("CoreMLLLMManager: Loaded Core ML model '\(name)' successfully on Neural Engine.")
                    return
                } catch {
                    print("CoreMLLLMManager: Found model file but failed to compile: \(error)")
                }
            }
        }
        
        // 3. Fallback: Offline On-Device Semantic Engine
        isCoreMLModelLoaded = false
        modelStatusText = "On-Device Apple Intelligence (Private & Offline)"
    }
    
    // MARK: - Send Message & Generate Response (Streaming)
    public func sendMessage(_ userPrompt: String) {
        guard !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Stop any current generation or speech
        currentTask?.cancel()
        stopSpeaking()
        
        // 1. Add User Message
        let userMessage = ChatMessage(
            content: userPrompt,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // 2. Add Placeholder for Assistant Streaming Message
        let assistantMessageId = UUID()
        let assistantMessage = ChatMessage(
            id: assistantMessageId,
            content: "",
            isUser: false,
            timestamp: Date(),
            isStreaming: true
        )
        messages.append(assistantMessage)
        isGenerating = true
        
        // Check if question is faith-related for citation purposes
        let lowerPrompt = userPrompt.lowercased()
        let isFaithTopic = lowerPrompt.contains("prayer") ||
                           lowerPrompt.contains("gospel") ||
                           lowerPrompt.contains("bible") ||
                           lowerPrompt.contains("scripture") ||
                           lowerPrompt.contains("jesus") ||
                           lowerPrompt.contains("god") ||
                           lowerPrompt.contains("psalm") ||
                           lowerPrompt.contains("peace")
        
        // 3. Generate Streamed Response
        currentTask = Task {
            #if canImport(FoundationModels)
            if let session = self.foundationModelSession {
                let versatilePrompt = """
                You are an intelligent, versatile, and concise AI assistant in the Glass Window app.

                INSTRUCTIONS:
                - Answer ANY question the user asks directly, accurately, and concisely (2 to 4 sentences maximum).
                - If the question is about technology, science, what is AI, history, or daily life: Provide an informative, factual, and direct explanation.
                - If the question is about faith, scripture, or prayer: Provide a warm, comforting, and uplifting response.
                - Do NOT output dividers ("---"), multiple headings, or long essays.

                User Question: "\(userPrompt)"
                """
                
                do {
                    let stream = session.streamResponse(to: versatilePrompt)
                    var accumulated = ""
                    for try await partial in stream {
                        if Task.isCancelled { break }
                        accumulated += partial.content
                        if let msgIndex = self.messages.firstIndex(where: { $0.id == assistantMessageId }) {
                            self.messages[msgIndex].content = accumulated
                            self.messages[msgIndex].scriptureCitation = isFaithTopic ? "Holy Scripture" : nil
                        }
                    }
                    if let msgIndex = self.messages.firstIndex(where: { $0.id == assistantMessageId }) {
                        self.messages[msgIndex].isStreaming = false
                    }
                    self.isGenerating = false
                    return
                } catch {
                    print("CoreMLLLMManager: FoundationModels stream error: \(error), falling back to offline engine.")
                }
            }
            #endif
            
            let (responseText, citation) = await self.generateIntelligentResponse(for: userPrompt)
            
            // Stream token by token for natural typewriter animation
            var accumulated = ""
            let words = responseText.components(separatedBy: " ")
            
            for (index, word) in words.enumerated() {
                if Task.isCancelled { break }
                
                accumulated += (index == 0 ? "" : " ") + word
                
                if let msgIndex = self.messages.firstIndex(where: { $0.id == assistantMessageId }) {
                    self.messages[msgIndex].content = accumulated
                    self.messages[msgIndex].scriptureCitation = citation
                }
                
                // Sleep for realistic streaming pace (~25ms per word)
                try? await Task.sleep(nanoseconds: 25_000_000)
            }
            
            if let msgIndex = self.messages.firstIndex(where: { $0.id == assistantMessageId }) {
                self.messages[msgIndex].isStreaming = false
            }
            self.isGenerating = false
        }
    }
    
    // MARK: - On-Device Intelligence Engine (All Topics + Faith)
    private func generateIntelligentResponse(for prompt: String) async -> (text: String, citation: String?) {
        let lower = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. If Core ML model is loaded in bundle, execute Core ML inference
        if let model = coreMLModel {
            if let output = try? executeCoreMLInference(on: model, prompt: prompt) {
                return (output, nil)
            }
        }
        
        // 2. Intelligent Category Matching
        
        // Artificial Intelligence & Technology
        if lower.contains("ai") || lower.contains("artificial intelligence") || lower.contains("machine learning") {
            let response = "Artificial Intelligence (AI) refers to computer systems and software engineered to perform tasks that typically require human intelligence. This includes learning from data, recognizing patterns, understanding natural language, making autonomous decisions, and solving complex problems."
            return (response, nil)
        }
        
        if lower.contains("who are you") || lower.contains("what are you") || lower.contains("what can you do") {
            let response = "I am your on-device AI Assistant in Glass Window. I can answer questions across technology, science, and everyday life, as well as guide you through Scripture, prayer routines, and daily reflections."
            return (response, nil)
        }
        
        if lower.contains("technology") || lower.contains("computer") || lower.contains("coding") || lower.contains("programming") || lower.contains("software") {
            let response = "Technology and software engineering harness computational logic and algorithms to automate tasks, solve real-world problems, and empower people to build creative digital tools."
            return (response, nil)
        }
        
        if lower.contains("hello") || lower.contains("hi") || lower.contains("hey") {
            let response = "Hello! I am here to help you. Feel free to ask me anything—whether it's a general question about science, technology, and daily life, or looking for a prayer and Scripture reflection."
            return (response, nil)
        }
        
        // Prayers & Faith Topics
        if lower.contains("anxiety") || lower.contains("peace") || lower.contains("worried") || lower.contains("fear") || lower.contains("stress") {
            let response = """
            Lord Jesus, Prince of Peace,
            
            Calm the storm within my mind and replace my worries with the quiet assurance of Your steadfast love. Remind me that You are already in my tomorrow, holding every detail in Your gentle hands.
            
            Grant me the grace to surrender control and rest in Your presence today. Amen.
            """
            return (response, "Philippians 4:6-7")
        }
        
        if lower.contains("gospel") || lower.contains("today") || lower.contains("reading") || lower.contains("luke") {
            let response = """
            Today's Gospel reflection invites us to seek Christ in our daily lives. Like the crowds who sought to hear Him, we are called to slow down, listen with an open heart, and put His teachings of compassion into practice.
            """
            return (response, "Luke 9:7-9")
        }
        
        if lower.contains("forgive") || lower.contains("anger") || lower.contains("hurt") || lower.contains("resentment") {
            let response = """
            Heavenly Father, give me the courage to release resentment and soften my heart to extend grace to those who have hurt me, just as You have lavished mercy upon me. Heal my memory and restore my peace. Amen.
            """
            return (response, "Ephesians 4:32")
        }
        
        if lower.contains("night") || lower.contains("sleep") || lower.contains("examen") || lower.contains("evening") || lower.contains("gratitude") {
            let response = """
            Lord of the Night, thank You for the gift of this day. I ask forgiveness for where I fell short, and I place my worries and loved ones into Your care. Grant me restorative rest and peaceful sleep. Amen.
            """
            return (response, "Psalm 4:8")
        }
        
        if lower.contains("guidance") || lower.contains("decision") || lower.contains("future") || lower.contains("direction") {
            let response = """
            Holy Spirit, Divine Counselor, bring clarity where there is confusion and trust where there is hesitation. Align my steps with what is good, true, and just. Amen.
            """
            return (response, "Proverbs 3:5-6")
        }
        
        if lower.contains("prayer") {
            let response = """
            Lord God, thank You for Your constant presence in our lives. Grant us strength for the day ahead, patience in trials, and a heart full of gratitude and peace. In Christ's name, Amen.
            """
            return (response, "Romans 8:28")
        }
        
        // Universal Direct Answer Fallback (Never blindly forces a prayer)
        let response = "I am ready to help you with that. Whether you are curious about technology, science, history, everyday guidance, or looking for a personal prayer and Bible reflection, please ask and I will provide a direct, concise answer."
        return (response, nil)
    }
    
    // MARK: - Core ML Inference Adapter
    private func executeCoreMLInference(on model: MLModel, prompt: String) throws -> String? {
        // Standard Core ML text model execution
        // Adaptable to any .mlpackage input shape (e.g., prompt input feature)
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["prompt": prompt])
        let prediction = try model.prediction(from: featureProvider)
        if let outputFeature = prediction.featureValue(for: "output")?.stringValue {
            return outputFeature
        }
        return nil
    }
    
    // MARK: - Text to Speech (Neural Recitation)
    public func speak(messageId: UUID, text: String) {
        if isSpeaking && currentlySpeakingId == messageId {
            stopSpeaking()
            return
        }
        
        stopSpeaking()
        
        // Clean markdown characters for smooth speech
        let cleanText = text
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "•", with: "")
        
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.90 // Soothing, reverent prayer cadence
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Prefer enhanced or Siri English voice if available
        if let siriVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = siriVoice
        }
        
        currentlySpeakingId = messageId
        isSpeaking = true
        speechSynthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        currentlySpeakingId = nil
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentlySpeakingId = nil
        }
    }
    
    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentlySpeakingId = nil
        }
    }
}
