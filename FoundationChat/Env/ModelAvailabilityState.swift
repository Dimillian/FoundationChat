import FoundationModels
import SwiftUI

enum ModelAvailabilityState: Equatable {
  case available
  case deviceIncompatible
  case intelligenceDisabled
  case modelDownloading
  case unknown(String)

  init(from availability: SystemLanguageModel.Availability) {
    switch availability {
    case .available:
      self = .available
    case .unavailable(.deviceNotEligible):
      self = .deviceIncompatible
    case .unavailable(.appleIntelligenceNotEnabled):
      self = .intelligenceDisabled
    case .unavailable(.modelNotReady):
      self = .modelDownloading
    case .unavailable(let reason):
      self = .unknown(String(describing: reason))
    }
  }

  var title: String {
    switch self {
    case .available:
      return ""
    case .deviceIncompatible:
      return "Device Not Compatible"
    case .intelligenceDisabled:
      return "Apple Intelligence Not Enabled"
    case .modelDownloading:
      return "Model Downloading"
    case .unknown:
      return "Apple Intelligence Unavailable"
    }
  }

  var systemImage: String {
    switch self {
    case .available:
      return ""
    case .deviceIncompatible:
      return "exclamationmark.triangle.fill"
    case .intelligenceDisabled:
      return "brain.head.profile.fill"
    case .modelDownloading:
      return "arrow.down.circle.fill"
    case .unknown:
      return "brain.head.profile.fill"
    }
  }

  var description: Text {
    switch self {
    case .available:
      return Text("")
    case .deviceIncompatible:
      return Text("Your device doesn't support Apple Intelligence. A compatible device is required for chat functionality.")
    case .intelligenceDisabled:
      return Text("Apple Intelligence is required for chat functionality. Please enable it in Settings > Apple Intelligence & Siri.")
    case .modelDownloading:
      return Text("The language model is still downloading. Please wait for the download to complete before using chat functionality.")
    case .unknown(let reason):
      return Text("Apple Intelligence is currently unavailable: \(reason)")
    }
  }
}
