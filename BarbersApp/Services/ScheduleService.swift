import Foundation

protocol ScheduleServiceProtocol: Sendable {
    func generateSlots(
        for date: Date,
        durationMinutes: Int,
        openingHour: Int,
        closingHour: Int,
        appointments: [Appointment],
        vacations: [VacationPeriod],
        referenceNow: Date
    ) -> [TimeSlot]
    
    func isVacation(on date: Date, vacations: [VacationPeriod]) -> (isVacation: Bool, reason: String?)
    func validateBooking(clientName: String, clientPhone: String) -> Result<Void, BookingValidationError>
}

enum BookingValidationError: LocalizedError, Equatable {
    case emptyName
    case invalidPhone
    case slotUnavailable
    case inVacationPeriod
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Please enter a valid client name."
        case .invalidPhone:
            return "Please enter a valid phone number (at least 7 digits)."
        case .slotUnavailable:
            return "This time slot is no longer available."
        case .inVacationPeriod:
            return "Cannot book an appointment during a vacation period."
        }
    }
}

struct ScheduleService: ScheduleServiceProtocol {
    init() {}
    
    func generateSlots(
        for date: Date,
        durationMinutes: Int = 45,
        openingHour: Int = 9,
        closingHour: Int = 19,
        appointments: [Appointment],
        vacations: [VacationPeriod],
        referenceNow: Date = Date()
    ) -> [TimeSlot] {
        let calendar = Calendar.current
        var slots: [TimeSlot] = []
        
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let dayOpening = calendar.date(bySettingHour: openingHour, minute: 0, second: 0, of: startOfDay),
              let dayClosing = calendar.date(bySettingHour: closingHour, minute: 0, second: 0, of: startOfDay) else {
            return []
        }
        
        var currentSlotStart = dayOpening
        let slotDuration = TimeInterval(durationMinutes * 60)
        
        // Active appointments for that day (ignore cancelled)
        let activeAppointments = appointments.filter { !$0.isCancelled }
        
        while currentSlotStart.addingTimeInterval(slotDuration) <= dayClosing {
            let currentSlotEnd = currentSlotStart.addingTimeInterval(slotDuration)
            
            // Check 1: In the past
            if currentSlotStart < referenceNow {
                slots.append(
                    TimeSlot(
                        startTime: currentSlotStart,
                        endTime: currentSlotEnd,
                        isAvailable: false,
                        unavailableReason: "Past"
                    )
                )
                currentSlotStart = currentSlotStart.addingTimeInterval(slotDuration)
                continue
            }
            
            // Check 2: Vacation Period
            let vacationOverlap = vacations.first { vacation in
                // Overlaps if slotStart < vacation.endDate && slotEnd > vacation.startDate
                currentSlotStart < vacation.endDate && currentSlotEnd > vacation.startDate
            }
            
            if let vacation = vacationOverlap {
                let reason = vacation.reason?.isEmpty == false ? vacation.reason! : "Barber on vacation"
                slots.append(
                    TimeSlot(
                        startTime: currentSlotStart,
                        endTime: currentSlotEnd,
                        isAvailable: false,
                        unavailableReason: reason
                    )
                )
                currentSlotStart = currentSlotStart.addingTimeInterval(slotDuration)
                continue
            }
            
            // Check 3: Existing booked appointment
            let appointmentOverlap = activeAppointments.first { appt in
                calendar.isDate(appt.date, inSameDayAs: date) &&
                abs(appt.date.timeIntervalSince(currentSlotStart)) < 60
            }
            
            if appointmentOverlap != nil {
                slots.append(
                    TimeSlot(
                        startTime: currentSlotStart,
                        endTime: currentSlotEnd,
                        isAvailable: false,
                        unavailableReason: "Booked"
                    )
                )
            } else {
                slots.append(
                    TimeSlot(
                        startTime: currentSlotStart,
                        endTime: currentSlotEnd,
                        isAvailable: true,
                        unavailableReason: nil
                    )
                )
            }
            
            currentSlotStart = currentSlotStart.addingTimeInterval(slotDuration)
        }
        
        return slots
    }
    
    func isVacation(on date: Date, vacations: [VacationPeriod]) -> (isVacation: Bool, reason: String?) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return (false, nil)
        }
        
        let matchingVacation = vacations.first { vacation in
            startOfDay < vacation.endDate && endOfDay > vacation.startDate
        }
        
        if let vacation = matchingVacation {
            return (true, vacation.reason)
        }
        return (false, nil)
    }
    
    func validateBooking(clientName: String, clientPhone: String) -> Result<Void, BookingValidationError> {
        let trimmedName = clientName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.count < 2 {
            return .failure(.emptyName)
        }
        
        let digitsOnly = clientPhone.filter { $0.isNumber }
        if digitsOnly.count < 7 {
            return .failure(.invalidPhone)
        }
        
        return .success(())
    }
}
