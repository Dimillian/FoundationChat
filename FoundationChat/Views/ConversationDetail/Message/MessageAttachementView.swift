import SwiftUI

struct MessageAttachementView: View {
  let message: Message

  var body: some View {
    if message.attachementTitle != nil || message.attachementThumbnail != nil
      || message.attachementDescription != nil
    {
      VStack {
        if let attachementThumbnail = message.attachementThumbnail {
          AsyncImage(url: URL(string: attachementThumbnail)) { state in
            if let image = state.image {
              image
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipped()
            } else {
              Color.secondary
            }
          }
        }
        if let attachementTitle = message.attachementTitle {
          Text(attachementTitle)
            .foregroundStyle(.white)
            .font(.title3)
            .contentTransition(.interpolate)
            .padding(.top)
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
        }
        if let attachementDescription = message.attachementDescription {
          Text(attachementDescription)
            .foregroundStyle(.white)
            .font(.subheadline)
            .contentTransition(.interpolate)
            .padding(.horizontal)
            .padding(.bottom)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .background(.secondary)
      .cornerRadius(16)
    }
  }
}
