import Foundation
import SwiftData
import Observation

@Observable
final class AdminDashboardViewModel {
    // MARK: - Selected Filter & Date
    var selectedDate: Date = Date()
    var activeTab: AdminTab = .today
    
    // MARK: - Sheet Presentation Flags
    var appointmentToCancel: Appointment? = nil
    var showCancelSheet: Bool = false
    var cancellationReasonText: String = ""
    
    var showManualBookingSheet: Bool = false
    var showVacationSheet: Bool = false
    
    // MARK: - Manual Booking State
    var manualClientName: String = ""
    var manualClientPhone: String = ""
    var manualSelectedService: BarberService = BarberService.sampleServices.first!
    var manualSelectedSlot: TimeSlot? = nil
    var manualBookingDate: Date = Date()
    var manualAvailableSlots: [TimeSlot] = []
    var manualErrorMessage: String? = nil
    
    // MARK: - Vacation Form State
    var newVacationStartDate: Date = Date()
    var newVacationEndDate: Date = Date().addingTimeInterval(3600 * 24 * 3) // +3 days
    var newVacationReason: String = ""
    
    private let scheduleService: ScheduleServiceProtocol
    
    enum AdminTab: String, CaseIterable, Identifiable {
        case today = "Today"
        case upcoming = "Agenda"
        case vacations = "Vacations"
        
        var id: String { rawValue }
    }
    
    init(scheduleService: ScheduleServiceProtocol = ScheduleService()) {
        self.scheduleService = scheduleService
    }
    
    // MARK: - Appointment Filters
    
    func appointments(for date: Date, from all: [Appointment]) -> [Appointment] {
        let calendar = Calendar.current
        return all
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    func upcomingAppointments(from all: [Appointment]) -> [Appointment] {
        let now = Date()
        return all
            .filter { $0.date >= now && !$0.isCancelled }
            .sorted { $0.date < $1.date }
    }
    
    func todayStats(appointments: [Appointment]) -> (total: Int, completed: Int, upcoming: Int, cancelled: Int) {
        let dayAppts = self.appointments(for: selectedDate, from: appointments)
        let now = Date()
        let cancelled = dayAppts.filter { $0.isCancelled }.count
        let active = dayAppts.filter { !$0.isCancelled }
        let completed = active.filter { $0.date < now }.count
        let upcoming = active.filter { $0.date >= now }.count
        return (total: dayAppts.count, completed: completed, upcoming: upcoming, cancelled: cancelled)
    }
    
    // MARK: - Cancellation Actions
    
    func prepareCancellation(for appointment: Appointment) {
        self.appointmentToCancel = appointment
        self.cancellationReasonText = ""
        self.showCancelSheet = true
    }
    
    func confirmCancellation(context: ModelContext) {
        guard let appointment = appointmentToCancel else { return }
        
        appointment.isCancelled = true
        let reason = cancellationReasonText.trimmingCharacters(in: .whitespacesAndNewlines)
        appointment.cancellationReason = reason.isEmpty ? "Cancelled by Barber" : reason
        
        try? context.save()
        self.showCancelSheet = false
        self.appointmentToCancel = nil
        self.cancellationReasonText = ""
    }
    
    // MARK: - Vacation Management
    
    func addVacation(context: ModelContext) {
        let reason = newVacationReason.trimmingCharacters(in: .whitespacesAndNewlines)
        let vacation = VacationPeriod(
            startDate: newVacationStartDate,
            endDate: newVacationEndDate,
            reason: reason.isEmpty ? "Vacation" : reason
        )
        context.insert(vacation)
        try? context.save()
        
        // Reset form
        newVacationReason = ""
        newVacationStartDate = Date()
        newVacationEndDate = Date().addingTimeInterval(3600 * 24 * 3)
    }
    
    func deleteVacation(_ vacation: VacationPeriod, context: ModelContext) {
        context.delete(vacation)
        try? context.save()
    }
    
    // MARK: - Manual In-Person Booking
    
    func prepareManualBooking(for date: Date = Date(), appointments: [Appointment], vacations: [VacationPeriod]) {
        self.manualBookingDate = date
        self.manualClientName = ""
        self.manualClientPhone = ""
        self.manualSelectedSlot = nil
        self.manualErrorMessage = nil
        refreshManualSlots(appointments: appointments, vacations: vacations)
        self.showManualBookingSheet = true
    }
    
    func refreshManualSlots(appointments: [Appointment], vacations: [VacationPeriod]) {
        self.manualAvailableSlots = scheduleService.generateSlots(
            for: manualBookingDate,
            durationMinutes: manualSelectedService.durationMinutes,
            openingHour: 8, // Extended opening hours for admin in-person flexibility
            closingHour: 20,
            appointments: appointments,
            vacations: vacations,
            referenceNow: Calendar.current.isDateInToday(manualBookingDate) ? Date() : .distantPast
        )
    }
    
    func confirmManualBooking(context: ModelContext, appointments: [Appointment], vacations: [VacationPeriod]) -> Bool {
        manualErrorMessage = nil
        
        let trimmedName = manualClientName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            manualErrorMessage = "Please enter the client's name."
            return false
        }
        
        guard let slot = manualSelectedSlot else {
            manualErrorMessage = "Please select a time slot."
            return false
        }
        
        let newAppt = Appointment(
            date: slot.startTime,
            clientName: trimmedName,
            clientPhone: manualClientPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "In-Person Walk-in" : manualClientPhone,
            serviceType: manualSelectedService.name,
            isCancelled: false,
            cancellationReason: nil
        )
        
        context.insert(newAppt)
        
        do {
            try context.save()
            self.showManualBookingSheet = false
            return true
        } catch {
            manualErrorMessage = "Failed to save booking: \(error.localizedDescription)"
            return false
        }
    }
}
