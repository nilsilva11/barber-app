import SwiftUI

enum AppTheme {
    // MARK: - Neutral Matte Color Palette
    
    // Backgrounds: Warm stone, canvas, and soft charcoal
    static let canvas = Color(light: Color(red: 0.96, green: 0.95, blue: 0.93),   // #F5F2ED Warm Sandstone
                              dark: Color(red: 0.12, green: 0.12, blue: 0.11))   // #1F1F1C Deep Matte Charcoal
    
    static let surface = Color(light: Color(red: 0.98, green: 0.98, blue: 0.97),  // #FAF9F7 Soft Alabaster
                               dark: Color(red: 0.16, green: 0.16, blue: 0.15))   // #292926 Warm Slate
    
    static let surfaceMuted = Color(light: Color(red: 0.92, green: 0.91, blue: 0.88), // #EAE8E0 Muted Oat
                                    dark: Color(red: 0.20, green: 0.20, blue: 0.19)) // #333330 Elevated Charcoal
    
    static let surfaceSelected = Color(light: Color(red: 0.22, green: 0.21, blue: 0.20), // #383633 Deep Espresso
                                       dark: Color(red: 0.88, green: 0.86, blue: 0.83)) // #E0DCD4 Warm Sand
    
    // Text Hierarchy
    static let textPrimary = Color(light: Color(red: 0.14, green: 0.14, blue: 0.13), // #242421 Espresso Charcoal
                                   dark: Color(red: 0.93, green: 0.92, blue: 0.90)) // #ECEAE6 Warm Bone
    
    static let textSecondary = Color(light: Color(red: 0.48, green: 0.46, blue: 0.44), // #7A7570 Muted Taupe
                                     dark: Color(red: 0.65, green: 0.63, blue: 0.60)) // #A6A199 Soft Muted Slate
    
    static let textTertiary = Color(light: Color(red: 0.65, green: 0.63, blue: 0.60), // #A6A199
                                    dark: Color(red: 0.48, green: 0.46, blue: 0.44))
    
    static let textOnSelected = Color(light: Color(red: 0.96, green: 0.95, blue: 0.93),
                                      dark: Color(red: 0.12, green: 0.12, blue: 0.11))
    
    // Subtle Hairline Borders
    static let borderSubtle = Color(light: Color(red: 0.88, green: 0.86, blue: 0.82), // #E0DCD1
                                    dark: Color(red: 0.25, green: 0.25, blue: 0.24)) // #40403D
    
    static let borderActive = Color(light: Color(red: 0.35, green: 0.33, blue: 0.31), // #59544F
                                    dark: Color(red: 0.70, green: 0.68, blue: 0.64)) // #B2ADA3
    
    // Muted Semantic Colors
    static let statusSuccess = Color(light: Color(red: 0.35, green: 0.45, blue: 0.35), // Muted Sage Olive
                                     dark: Color(red: 0.55, green: 0.68, blue: 0.55))
    
    static let statusWarning = Color(light: Color(red: 0.62, green: 0.48, blue: 0.32), // Warm Ochre
                                     dark: Color(red: 0.80, green: 0.66, blue: 0.48))
    
    static let statusMutedBadge = Color(light: Color(red: 0.88, green: 0.85, blue: 0.81),
                                        dark: Color(red: 0.22, green: 0.22, blue: 0.21))
}

// MARK: - Helvetica Typography System
enum AppFont {
    static func helvetica(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .ultraLight, .thin:
            return .custom("HelveticaNeue-UltraLight", size: size)
        case .light:
            return .custom("HelveticaNeue-Light", size: size)
        case .regular:
            return .custom("HelveticaNeue", size: size)
        case .medium:
            return .custom("HelveticaNeue-Medium", size: size)
        case .semibold, .bold:
            return .custom("HelveticaNeue-Bold", size: size)
        case .heavy, .black:
            return .custom("HelveticaNeue-CondensedBlack", size: size)
        default:
            return .custom("HelveticaNeue", size: size)
        }
    }
}

// MARK: - Dynamic Light/Dark Color Helper
extension Color {
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self = light
        #endif
    }
}
