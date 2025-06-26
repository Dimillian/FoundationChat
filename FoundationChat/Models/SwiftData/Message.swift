import Foundation
import SwiftData

@Model
final class Message {
  var content: String
  var role: Role
  var timestamp: Date

  var attachementTitle: String?
  var attachementDescription: String?
  var attachementThumbnail: String?
  var attachementSummary: String?

  init(
    content: String, role: Role, timestamp: Date,
    attachementTitle: String? = nil,
    attachementDescription: String? = nil,
    attachementThumbnail: String? = nil,
  ) {
    self.content = content
    self.role = role
    self.timestamp = timestamp
    self.attachementTitle = attachementTitle
    self.attachementThumbnail = attachementThumbnail
  }
}
