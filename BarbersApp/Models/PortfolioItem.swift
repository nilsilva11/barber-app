import Foundation
import SwiftData
import SwiftUI

enum CutCategory: String, CaseIterable, Identifiable, Codable {
    case classic = "classic"
    case fade = "fade"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .classic: return "Classic Cuts"
        case .fade: return "Fade Cuts"
        }
    }
    
    var subtitle: String {
        switch self {
        case .classic: return "Timeless scissor craftsmanship & tailored volume"
        case .fade: return "Precision skin fades, tapers & sharp contours"
        }
    }
    
    var coverAssetName: String {
        switch self {
        case .classic: return "classic_cover"
        case .fade: return "fade_cover"
        }
    }
    
    var associatedServiceName: String {
        switch self {
        case .classic: return "Classic Haircut"
        case .fade: return "Fade Haircut"
        }
    }
}

@Model
final class PortfolioItem {
    var id: UUID
    var title: String
    var categoryRaw: String
    var assetName: String?
    @Attribute(.externalStorage) var customImageData: Data?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        category: CutCategory,
        assetName: String? = nil,
        customImageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.categoryRaw = category.rawValue
        self.assetName = assetName
        self.customImageData = customImageData
        self.createdAt = createdAt
    }
    
    var category: CutCategory {
        get { CutCategory(rawValue: categoryRaw) ?? .classic }
        set { categoryRaw = newValue.rawValue }
    }
    
    @ViewBuilder
    func renderImage() -> some View {
        if let data = customImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        } else if let asset = assetName {
            Image(asset)
                .resizable()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
        }
    }
    
    // Seed initial portfolio work if database is unpopulated
    static func seedDefaultItems(context: ModelContext) {
        let descriptor = FetchDescriptor<PortfolioItem>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }
        
        let classicDefaults = [
            PortfolioItem(title: "Executive Scissor Taper", category: .classic, assetName: "classic1"),
            PortfolioItem(title: "Textured Side Part", category: .classic, assetName: "classic2"),
            PortfolioItem(title: "Modern Pompadour", category: .classic, assetName: "classic3"),
            PortfolioItem(title: "Classic Clean Taper", category: .classic, assetName: "classic4")
        ]
        
        let fadeDefaults = [
            PortfolioItem(title: "Low Skin Fade & Crop", category: .fade, assetName: "fade1"),
            PortfolioItem(title: "Mid Drop Fade", category: .fade, assetName: "fade2"),
            PortfolioItem(title: "High Taper Fade", category: .fade, assetName: "fade3"),
            PortfolioItem(title: "Skin Fade & Line Up", category: .fade, assetName: "fade4")
        ]
        
        for item in classicDefaults + fadeDefaults {
            context.insert(item)
        }
        try? context.save()
    }
}
