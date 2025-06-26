import SwiftData
import SwiftUI
import FoundationModels

struct ConversationsListView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var conversations: [Conversation]

  @State private var path: [Conversation] = []
  
  private var isModelAvailable: Bool {
    SystemLanguageModel.default.isAvailable
  }

  var body: some View {
    NavigationStack(path: $path) {
      if isModelAvailable {
        List {
          ForEach(conversations.sorted(by: { $0.lastMessageTimestamp > $1.lastMessageTimestamp })) {
            conversation in
            NavigationLink(value: conversation) {
              ConversationRowView(conversation: conversation)
                .swipeActions {
                  Button(role: .destructive) {
                    modelContext.delete(conversation)
                    try? modelContext.save()
                  } label: {
                    Label("Delete", systemImage: "trash")
                  }
                }
            }
          }
          .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .navigationDestination(for: Conversation.self) { conversation in
          ConversationDetailView(conversation: conversation)
            .environment(ChatEngine(conversation: conversation))
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              let newConversation = Conversation(messages: [], summary: "New conversation")
              modelContext.insert(newConversation)
              try? modelContext.save()
              path.append(newConversation)
            } label: {
              Image(systemName: "plus")
            }
          }
        }
      } else {
        ContentUnavailableView(
          "Apple Intelligence Required",
          systemImage: "brain.head.profile.fill",
          description: Text("This app requires Apple Intelligence to be available for chat functionality. Please ensure your device supports it and it's enabled in Settings.")
        )
      }
    }
    .navigationTitle("Conversations")
    .navigationBarTitleDisplayMode(.inline)
  }
}
