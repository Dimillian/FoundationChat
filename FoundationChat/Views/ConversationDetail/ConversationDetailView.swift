import FoundationModels
import SwiftData
import SwiftUI

struct ConversationDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(ChatEngine.self) private var chatEngine

  @State var newMessage: String = ""
  @State var conversation: Conversation
  @State var scrollPosition: ScrollPosition = .init()
  @State var isGenerating: Bool = false
  @State private var refreshTrigger = false
  @FocusState var isInputFocused: Bool

  var body: some View {
    Group {
      if chatEngine.isAvailable {
        ScrollView {
          LazyVStack {
            ForEach(conversation.sortedMessages) { message in
              ConversationMessageView(message: message)
                .id(message.id)
            }
          }
          .scrollTargetLayout()
          .padding(.bottom, 50)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollPosition($scrollPosition, anchor: .bottom)
        .toolbar {
          ConversationDetailInputView(
            newMessage: $newMessage,
            isGenerating: $isGenerating,
            isInputFocused: $isInputFocused,
            onSend: {
              isGenerating = true
              try? await streamNewMessage()
              try? await updateConversationSummary()
              isGenerating = false
            }
          )
        }
        .onAppear {
          chatEngine.prewarm()
          isInputFocused = true
          withAnimation {
            scrollPosition.scrollTo(edge: .bottom)
          }
        }
      } else {
        ContentUnavailableView {
          Label(chatEngine.availabilityState.title, systemImage: chatEngine.availabilityState.systemImage)
        } description: {
          chatEngine.availabilityState.description
        } actions: {
          if chatEngine.availabilityState == .modelDownloading || chatEngine.availabilityState == .intelligenceDisabled {
            Button("Check Again") {
              refreshTrigger.toggle()
            }
            .buttonStyle(.borderedProminent)
          }
        }
      }
    }
    .id(refreshTrigger)
    .navigationTitle("Messages")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarRole(.editor)
  }
}

extension ConversationDetailView {
  private func streamNewMessage() async throws {
    conversation.messages.append(
      Message(
        content: newMessage, role: .user,
        timestamp: Date()))
    try? modelContext.save()
    newMessage = ""
    withAnimation {
      scrollPosition.scrollTo(edge: .bottom)
    }
    if let stream = await chatEngine.respondTo() {
      let newMessage = Message(
        content: "...",
        role: .assistant,
        timestamp: Date())
      conversation.messages.append(newMessage)
      for try await part in stream {
        newMessage.content = part.content ?? ""
        scrollPosition.scrollTo(edge: .bottom)
      }
      try modelContext.save()
    }
  }

  private func updateConversationSummary() async throws {
    if let stream = await chatEngine.summarize() {
      for try await part in stream {
        conversation.summary = part
      }
      try modelContext.save()
    }
  }
}
