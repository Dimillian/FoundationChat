import FoundationModels
import Playgrounds
import SwiftUI

@Observable
class ChatEngine {
  private let model = SystemLanguageModel.default
  private let session: LanguageModelSession
  private let conversation: Conversation

  var availabilityState: ModelAvailabilityState {
    ModelAvailabilityState(from: model.availability)
  }

  var isAvailable: Bool {
    model.isAvailable
  }

  var conversationHistory: String {
    conversation.sortedMessages.map {
      "Role: \($0.role.rawValue)\nContent: \($0.content)"
    }.joined(separator: "\n\n")
  }

  var conversationHistorySize: Int {
    conversationHistory.components(separatedBy: .whitespacesAndNewlines).count
  }

  init(conversation: Conversation) {
    self.conversation = conversation
    session = LanguageModelSession {
      """
      You're an helpful chatbot. The user will send you messages, and you'll respond to them.
      Be short, it's a chat application.
      You can also summarize the conversation when asked to.
      Each messages will have a role, either user or assistant or system for initial conversation configuration.
      """
    }
  }

  func prewarm() {
    session.prewarm()
  }

  func respondTo() async -> LanguageModelSession.ResponseStream<MessageGenerable>? {
    guard isAvailable else { return nil }

    if conversationHistorySize < 4000 {
      return session.streamResponse(generating: MessageGenerable.self) {
        """
        Here is the conversation history:
        \(conversationHistory)
        Respond with the assistant role to the user last message.
        """
      }
    } else {
      return session.streamResponse(generating: MessageGenerable.self) {
        """
        Here is the conversation summary:
        \(conversation.summary ?? "No summary available")
        And the last message from the user:
        \(conversation.messages.last?.content ?? "No message available")
        Respond with the assistant role to the user last message.
        """
      }
    }
  }

  func summarize() async -> LanguageModelSession.ResponseStream<String>? {
    guard isAvailable else { return nil }

    if conversationHistorySize < 4000 {
      return session.streamResponse {
        """
        Summarize the conversation in one or two sentences for the user. Don't talk about the conversation, just the topic.
        Also don't mention "The user" or "The assistant" or "The conversation"
        The goal of the summary if for the user or you to know what the conversation is about.
        Here is the conversation history
        \(conversationHistory)
        """
      }
    } else {
      return session.streamResponse {
        """
        Summarize the conversation in one or two sentences for the user. Don't talk about the conversation, just the topic.
        Also don't mention "The user" or "The assistant" or "The conversation"
        Here is the previous conversation summary:
        \(conversation.summary ?? "No summary available")
        And the last message is:
        \(conversation.messages.last?.content ?? "No message available")
        """
      }
    }
  }
}
