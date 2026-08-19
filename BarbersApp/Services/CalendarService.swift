import Foundation
import EventKit

enum CalendarServiceError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case noDefaultCalendar
    case failedToSave(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Calendar access was denied. You can enable it in iOS Settings to save appointments."
        case .permissionRestricted:
            return "Calendar access is restricted on this device."
        case .noDefaultCalendar:
            return "No default calendar found on your device."
        case .failedToSave(let reason):
            return "Could not add appointment to calendar: \(reason)"
        case .unknown:
            return "An unexpected error occurred while accessing the calendar."
        }
    }
}

protocol CalendarServiceProtocol: Sendable {
    func addAppointment(
        appointment: Appointment,
        durationMinutes: Int?,
        location: String
    ) async throws -> String
}

final class CalendarService: CalendarServiceProtocol {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    
    init() {}
    
    /// Requests write-only (or full) calendar access from the user
    private func requestCalendarAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestWriteOnlyAccessToEvents()
            } catch {
                throw CalendarServiceError.failedToSave(error.localizedDescription)
            }
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: CalendarServiceError.failedToSave(error.localizedDescription))
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    /// Adds the given appointment to the user's default iOS Calendar
    /// - Returns: The created EKEvent identifier string
    func addAppointment(
        appointment: Appointment,
        durationMinutes: Int? = nil,
        location: String = "Matos Barbershop"
    ) async throws -> String {
        // 1. Check authorization status
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .restricted:
            throw CalendarServiceError.permissionRestricted
        case .denied:
            throw CalendarServiceError.permissionDenied
        case .notDetermined:
            let granted = try await requestCalendarAccess()
            guard granted else {
                throw CalendarServiceError.permissionDenied
            }
        default:
            // .authorized, .fullAccess, or .writeOnly
            break
        }
        
        // 2. Determine duration based on service type or provided parameter
        let duration: Int
        if let durationMinutes = durationMinutes, durationMinutes > 0 {
            duration = durationMinutes
        } else {
            let matchedService = BarberService.sampleServices.first {
                $0.name.localizedCaseInsensitiveCompare(appointment.serviceType) == .orderedSame
            }
            duration = matchedService?.durationMinutes ?? 45
        }
        
        // 3. Resolve matched service for price info
        let matchedService = BarberService.sampleServices.first {
            $0.name.localizedCaseInsensitiveCompare(appointment.serviceType) == .orderedSame
        }
        let priceNote = matchedService != nil ? String(format: "Price: €%.0f\n", matchedService!.price) : ""
        
        // 4. Create EKEvent
        let event = EKEvent(eventStore: eventStore)
        event.title = "\(appointment.serviceType) - Matos Barbershop"
        event.startDate = appointment.date
        event.endDate = appointment.date.addingTimeInterval(TimeInterval(duration * 60))
        event.location = location
        
        event.notes = """
        Service: \(appointment.serviceType)
        \(priceNote)Client: \(appointment.clientName)
        Contact: \(appointment.clientPhone)
        Location: \(location)
        
        Booked via Matos Barbershop App
        """
        
        // 5. Add reminder alerts
        // Alarm 1: 1 hour before
        event.addAlarm(EKAlarm(relativeOffset: -3600))
        
        // Alarm 2: 1 day before (if booking is at least 24h away)
        if appointment.date.timeIntervalSinceNow > 86400 {
            event.addAlarm(EKAlarm(relativeOffset: -86400))
        }
        
        // 6. Set calendar
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarServiceError.noDefaultCalendar
        }
        event.calendar = defaultCalendar
        
        // 7. Save to Event Store
        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier ?? UUID().uuidString
        } catch {
            throw CalendarServiceError.failedToSave(error.localizedDescription)
        }
    }
}
