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
              await streamNewMessage()
              await updateConversationSummary()
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
  private func streamNewMessage() async {
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
      
      do {
        for try await part in stream {
          newMessage.content = part.content ?? ""
          scrollPosition.scrollTo(edge: .bottom)
        }
        try modelContext.save()
      } catch {
        newMessage.content = "Error: \(error.localizedDescription)"
      }
    }
  }

  private func updateConversationSummary() async {
    if let stream = await chatEngine.summarize() {
      do {
        for try await part in stream {
          conversation.summary = part
        }
        try modelContext.save()
      } catch {
        conversation.summary = "Error: \(error.localizedDescription)"
      }
    }
  }
}
