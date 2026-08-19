import Foundation
import SwiftData

@Model
final class VacationPeriod {
    var startDate: Date
    var endDate: Date
    var reason: String?
    
    init(startDate: Date, endDate: Date, reason: String? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.reason = reason
    }
}
