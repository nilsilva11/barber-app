import Foundation
import SwiftData

@Model
final class Appointment {
    var date: Date
    var clientName: String
    var clientPhone: String
    var serviceType: String
    var isCancelled: Bool
    var cancellationReason: String?
    
    init(date: Date, clientName: String, clientPhone: String, serviceType: String, isCancelled: Bool = false, cancellationReason: String? = nil) {
        self.date = date
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.serviceType = serviceType
        self.isCancelled = isCancelled
        self.cancellationReason = cancellationReason
    }
}
