import Foundation
import SwiftUI
import ScrapCore
#if canImport(UIKit)
import UIKit
#endif

/// Draws one post photo: an online image, a photo picked on this device, or a sample stand-in.
struct ScpPostPhotoView: View {
    let photo: ScpPostPhoto

    var body: some View {
        switch photo {
        case .remote(let url):
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ScpColor.chip
            }
        case .data(let data):
            localImage(data)
        case .placeholder(let name):
            placeholder(named: name)
        }
    }

    @ViewBuilder
    private func localImage(_ data: Data) -> some View {
        #if canImport(UIKit)
        if let image = UIImage(data: data) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            ScpColor.chip
        }
        #else
        ScpColor.chip
        #endif
    }

    /// Sample posts have no real photos yet, so they get a warm gradient and a dish emoji.
    private func placeholder(named name: String) -> some View {
        ZStack {
            LinearGradient(
                colors: [ScpColor.photoPlaceholderTop, ScpColor.photoPlaceholderBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(Self.emoji(for: name))
                .font(.system(size: 96))
        }
    }

    private static func emoji(for name: String) -> String {
        switch name {
        case "pasta": return "🍝"
        case "gnocchi": return "🥔"
        case "mealprep": return "🥗"
        case "pancakes": return "🥞"
        case "ramen": return "🍜"
        default: return "🍽️"
        }
    }
}

/// One or more post photos in a rounded frame. Several photos can be swiped through.
struct ScpPostPhotoGallery: View {
    let photos: [ScpPostPhoto]
    var height: CGFloat = 260

    var body: some View {
        Group {
            if photos.count > 1 {
                TabView {
                    ForEach(Array(photos.enumerated()), id: \.offset) { _, photo in
                        ScpPostPhotoView(photo: photo)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            } else if let photo = photos.first {
                ScpPostPhotoView(photo: photo)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityLabel(Text("Photo of the dish"))
    }
}
