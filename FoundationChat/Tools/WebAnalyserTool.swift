import Foundation
import FoundationModels
import SwiftSoup

struct WebAnalyserTool: Tool {
  let name: String = "WebAnalyser"
  let description: String =
    "Analyse a website and return the content in a structured way, like page title, description and summary"
  private let session = URLSession.shared

  @Generable
  struct Arguments {
    @Guide(description: "The URL of the webpage to analyze")
    let url: String
  }

  func call(arguments: Arguments) async throws -> ToolOutput {
    guard let url = URL(string: arguments.url) else {
      return ToolOutput("Invalid URL provided: \(arguments.url)")
    }
    let (data, _) = try await session.data(from: url)
    let html = String(data: data, encoding: .utf8)!
    let soup = try SwiftSoup.parse(html)
    let title = try soup.title()
    let thumbnail = try soup.select("meta[property='og:image']").attr("content")
    let description = try soup.select("meta[name='description']").attr("content")
    return ToolOutput(
      GeneratedContent(
        WebPageMetadata(
          title: title, thumbnail: thumbnail, description: description)))
  }
}
