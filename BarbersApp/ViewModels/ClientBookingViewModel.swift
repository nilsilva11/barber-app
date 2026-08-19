import Foundation
import SwiftData
import Observation

@Observable
final class ClientBookingViewModel {
    // MARK: - Properties
    var selectedDate: Date = Date()
    var selectedService: BarberService
    var selectedSlot: TimeSlot?
    var clientName: String = ""
    var clientPhone: String = ""
    
    var availableServices: [BarberService]
    var slots: [TimeSlot] = []
    
    var isVacationDay: Bool = false
    var vacationReason: String? = nil
    
    var isSubmitting: Bool = false
    var bookingSuccess: Bool = false
    var errorMessage: String? = nil
    var createdAppointment: Appointment? = nil
    
    private let scheduleService: ScheduleServiceProtocol
    
    // MARK: - Init
    init(
        scheduleService: ScheduleServiceProtocol = ScheduleService(),
        services: [BarberService] = BarberService.sampleServices,
        initialDate: Date = Date()
    ) {
        self.scheduleService = scheduleService
        self.availableServices = services
        self.selectedService = services.first ?? BarberService(
            name: "Haircut",
            durationMinutes: 45,
            price: 30.0,
            iconName: "scissors",
            description: "Standard cut"
        )
        self.selectedDate = initialDate
    }
    
    // MARK: - Computed State
    var availableSlots: [TimeSlot] {
        slots.filter { $0.isAvailable }
    }
    
    var canBook: Bool {
        guard selectedSlot != nil, selectedSlot?.isAvailable == true else { return false }
        let validation = scheduleService.validateBooking(clientName: clientName, clientPhone: clientPhone)
        switch validation {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    // MARK: - Actions
    func selectDate(_ date: Date, appointments: [Appointment], vacations: [VacationPeriod]) {
        self.selectedDate = date
        self.selectedSlot = nil
        refreshSlots(appointments: appointments, vacations: vacations)
    }
    
    func selectService(_ service: BarberService, appointments: [Appointment], vacations: [VacationPeriod]) {
        self.selectedService = service
        self.selectedSlot = nil
        refreshSlots(appointments: appointments, vacations: vacations)
    }
    
    func selectSlot(_ slot: TimeSlot) {
        guard slot.isAvailable else { return }
        self.selectedSlot = slot
        self.errorMessage = nil
    }
    
    func refreshSlots(
        appointments: [Appointment],
        vacations: [VacationPeriod],
        referenceNow: Date = Date()
    ) {
        let (isVac, reason) = scheduleService.isVacation(on: selectedDate, vacations: vacations)
        self.isVacationDay = isVac
        self.vacationReason = reason
        
        self.slots = scheduleService.generateSlots(
            for: selectedDate,
            durationMinutes: selectedService.durationMinutes,
            openingHour: 9,
            closingHour: 19,
            appointments: appointments,
            vacations: vacations,
            referenceNow: referenceNow
        )
        
        // If current selected slot is no longer available in new slots, clear selection
        if let currentSelected = selectedSlot {
            let stillAvailable = slots.contains { $0.startTime == currentSelected.startTime && $0.isAvailable }
            if !stillAvailable {
                self.selectedSlot = nil
            }
        }
    }
    
    @MainActor
    func bookAppointment(
        context: ModelContext,
        appointments: [Appointment],
        vacations: [VacationPeriod]
    ) -> Bool {
        errorMessage = nil
        
        // Validate inputs
        let validation = scheduleService.validateBooking(clientName: clientName, clientPhone: clientPhone)
        switch validation {
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            return false
        case .success:
            break
        }
        
        guard let slot = selectedSlot else {
            self.errorMessage = "Please select an available time slot."
            return false
        }
        
        guard slot.isAvailable else {
            self.errorMessage = BookingValidationError.slotUnavailable.localizedDescription
            return false
        }
        
        // Final guard against race conditions / overlaps
        let isOverlapping = appointments.contains { appt in
            !appt.isCancelled &&
            Calendar.current.isDate(appt.date, inSameDayAs: slot.startTime) &&
            abs(appt.date.timeIntervalSince(slot.startTime)) < 60
        }
        
        if isOverlapping {
            self.errorMessage = BookingValidationError.slotUnavailable.localizedDescription
            refreshSlots(appointments: appointments, vacations: vacations)
            return false
        }
        
        isSubmitting = true
        
        let newAppointment = Appointment(
            date: slot.startTime,
            clientName: clientName.trimmingCharacters(in: .whitespacesAndNewlines),
            clientPhone: clientPhone.trimmingCharacters(in: .whitespacesAndNewlines),
            serviceType: selectedService.name,
            isCancelled: false,
            cancellationReason: nil
        )
        
        context.insert(newAppointment)
        
        do {
            try context.save()
            self.createdAppointment = newAppointment
            self.bookingSuccess = true
            self.isSubmitting = false
            return true
        } catch {
            self.errorMessage = "Failed to save booking: \(error.localizedDescription)"
            self.isSubmitting = false
            return false
        }
    }
    
    func resetForm() {
        self.clientName = ""
        self.clientPhone = ""
        self.selectedSlot = nil
        self.bookingSuccess = false
        self.errorMessage = nil
        self.createdAppointment = nil
    }
}
