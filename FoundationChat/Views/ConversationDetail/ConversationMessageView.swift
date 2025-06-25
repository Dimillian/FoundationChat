import SwiftUI

struct ConversationMessageView: View {
  let message: Message

  var body: some View {
    HStack {
      if message.role == .user {
        Spacer()
      }
      VStack(alignment: .leading) {
        Text(message.content)
          .foregroundStyle(.white)
          .font(.subheadline)
          .contentTransition(.interpolate)
      }
      .padding()
      .glassEffect(
        .regular.tint(message.role == .user ? .blue : .green), in: .rect(cornerRadius: 16)
      )
      .padding(.horizontal)
      .animation(.bouncy, value: message.content)
      if message.role == .assistant {
        Spacer()
      }
    }
  }
}
