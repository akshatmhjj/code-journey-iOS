import SwiftUI

/// Code Journey brand fonts. Sizes still scale with the user's Dynamic Type setting.
/// The names below are the font's PostScript names, not the file names.
enum CJFont {
    /// Headings: Familjen Grotesk Bold.
    static func display(_ size: CGFloat) -> Font {
        .custom("FamiljenGrotesk-Bold", size: size, relativeTo: .largeTitle)
    }

    /// Body text: IBM Plex Sans Regular.
    static func body(_ size: CGFloat = 17) -> Font {
        .custom("IBMPlexSans-Regular", size: size, relativeTo: .body)
    }

    /// Small uppercase labels: IBM Plex Mono Medium.
    static func label(_ size: CGFloat = 12) -> Font {
        .custom("IBMPlexMono-Medium", size: size, relativeTo: .caption)
    }
}
