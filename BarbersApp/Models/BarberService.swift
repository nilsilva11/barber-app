import Foundation

struct BarberService: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let durationMinutes: Int
    let price: Double
    let iconName: String
    let description: String
    
    init(id: String = UUID().uuidString, name: String, durationMinutes: Int, price: Double, iconName: String, description: String) {
        self.id = id
        self.name = name
        self.durationMinutes = durationMinutes
        self.price = price
        self.iconName = iconName
        self.description = description
    }
    
    static let sampleServices: [BarberService] = [
        BarberService(
            id: "classic-haircut",
            name: "Classic Haircut",
            durationMinutes: 45,
            price: 8.0,
            iconName: "scissors",
            description: "Precision haircut tailored to your style, includes wash and styling."
        ),
        BarberService(
            id: "fade-haircut",
            name: "Fade Haircut",
            durationMinutes: 60,
            price: 10.0,
            iconName: "clipper",
            description: "Scissors and clippers for a clean, modern cut. Includes wash and styling."
        ),
        BarberService(
            id: "hair-beard-combo",
            name: "Hair & Beard Combo",
            durationMinutes: 60,
            price: 12.0,
            iconName: "scissors+mustache",
            description: "The complete grooming package: full haircut and beard styling."
        ),
        BarberService(
            id: "beard-trim",
            name: "Beard Trim",
            durationMinutes: 30,
            price: 6.0,
            iconName: "mustache.fill",
            description: "Beard shaping, line-up, trimmer work, and beard oil application."
        ),
        BarberService(
            id: "hot-towel-shave",
            name: "Hot Towel Shave",
            durationMinutes: 30,
            price: 8.0,
            iconName: "sparkles",
            description: "Traditional straight-razor shave with essential oils and hot towel treatment."
        )
    ]
}
