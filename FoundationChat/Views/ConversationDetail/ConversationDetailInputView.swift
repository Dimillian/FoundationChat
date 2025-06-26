import SwiftUI

struct ConversationDetailInputView: ToolbarContent {
  @Binding var newMessage: String
  @Binding var isGenerating: Bool
  var isInputFocused: FocusState<Bool>.Binding

  var onSend: () async throws -> Void

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .bottomBar) {
      TextField("New message to the assistant", text: $newMessage)
        .textFieldStyle(.plain)
        .padding()
        .contentShape(Rectangle())
        .focused(isInputFocused)
      Button(action: {
        Task {
          try? await onSend()
        }
      }) {
        Label("Send", systemImage: "paperplane")
      }
      .disabled(isGenerating)
      .tint(isGenerating ? .gray : .blue)
    }
  }
}

#Preview {
  @FocusState var isInputFocused: Bool
  
  NavigationStack {
    List {
      Text("Hello")
    }
    .toolbar {
      ConversationDetailInputView(newMessage: .constant(""),
                                  isGenerating: .constant(false),
                                  isInputFocused: $isInputFocused,
                                  onSend: { })
    }
  }
}
