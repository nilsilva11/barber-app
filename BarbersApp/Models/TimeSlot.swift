import Foundation

struct TimeSlot: Identifiable, Hashable, Sendable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let isAvailable: Bool
    let unavailableReason: String?
    
    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        isAvailable: Bool,
        unavailableReason: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.isAvailable = isAvailable
        self.unavailableReason = unavailableReason
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: startTime)
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}
