import SwiftUI
import SwiftData

struct ManualBookingSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var vacations: [VacationPeriod]
    
    @State private var clientName: String = ""
    @State private var clientPhone: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedService: BarberService = BarberService.sampleServices.first!
    @State private var selectedSlot: TimeSlot? = nil
    @State private var slots: [TimeSlot] = []
    @State private var errorMessage: String? = nil
    
    let onDismiss: () -> Void
    
    private let scheduleService = ScheduleService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.canvas.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        // SECTION 1: Client Details
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(title: "01 / CLIENT DETAILS")
                            
                            VStack(spacing: 12) {
                                inputField(label: "Client Name", placeholder: "e.g. Robert Fox", icon: "person", text: $clientName)
                                inputField(label: "Phone Number (Optional)", placeholder: "e.g. +351 912 345 678", icon: "phone", text: $clientPhone, keyboardType: .phonePad)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 12)
                        
                        // SECTION 2: Service Selection
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(title: "02 / SELECT SERVICE")
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(BarberService.sampleServices) { service in
                                        let isSelected = selectedService.id == service.id
                                        Button {
                                            selectedService = service
                                            selectedSlot = nil
                                            refreshSlots()
                                        } label: {
                                            HStack(spacing: 10) {
                                                ServiceIconView(iconName: service.iconName, isSelected: isSelected)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(service.name)
                                                        .font(AppFont.helvetica(size: 13, weight: .bold))
                                                    Text("€\(Int(service.price)) • \(service.durationMinutes)m")
                                                        .font(AppFont.helvetica(size: 11, weight: .regular))
                                                        .foregroundColor(isSelected ? AppTheme.textOnSelected.opacity(0.8) : AppTheme.textSecondary)
                                                }
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(isSelected ? AppTheme.surfaceSelected : AppTheme.surface)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(isSelected ? AppTheme.borderActive : AppTheme.borderSubtle, lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // SECTION 3: Date Picker
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(title: "03 / DATE")
                            
                            DatePicker(
                                "Appointment Date",
                                selection: $selectedDate,
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                            .font(AppFont.helvetica(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .tint(AppTheme.surfaceSelected)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .onChange(of: selectedDate) {
                                selectedSlot = nil
                                refreshSlots()
                            }
                        }
                        
                        // SECTION 4: Available Time Slots
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(title: "04 / AVAILABLE TIME SLOT")
                            
                            let availableSlots = slots.filter { $0.isAvailable }
                            if availableSlots.isEmpty {
                                Text("No available slots for this date/service.")
                                    .font(AppFont.helvetica(size: 12, weight: .regular))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal, 20)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(slots) { slot in
                                        let isSelected = selectedSlot?.id == slot.id
                                        
                                        Button {
                                            if slot.isAvailable {
                                                selectedSlot = slot
                                            }
                                        } label: {
                                            VStack(spacing: 2) {
                                                Text(slot.formattedStartTime)
                                                    .font(AppFont.helvetica(size: 13, weight: isSelected ? .bold : .medium))
                                                    .foregroundColor(
                                                        isSelected ? AppTheme.textOnSelected : (slot.isAvailable ? AppTheme.textPrimary : AppTheme.textTertiary)
                                                    )
                                                
                                                Text(slot.isAvailable ? "Free" : (slot.unavailableReason ?? "Booked"))
                                                    .font(AppFont.helvetica(size: 9, weight: .regular))
                                                    .foregroundColor(
                                                        isSelected ? AppTheme.textOnSelected.opacity(0.8) : (slot.isAvailable ? AppTheme.statusSuccess : AppTheme.textTertiary)
                                                    )
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 46)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        isSelected ? AppTheme.surfaceSelected : (slot.isAvailable ? AppTheme.surface : AppTheme.surfaceMuted.opacity(0.5))
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        isSelected ? AppTheme.borderActive : (slot.isAvailable ? AppTheme.borderSubtle : AppTheme.borderSubtle.opacity(0.4)),
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(!slot.isAvailable)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Error message banner
                        if let error = errorMessage {
                            Text(error)
                                .font(AppFont.helvetica(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.statusWarning)
                                .padding(.horizontal, 20)
                        }
                        
                        // Confirm Button
                        Button {
                            submitBooking()
                        } label: {
                            Text("Create In-Person Appointment")
                                .font(AppFont.helvetica(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textOnSelected)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(canSubmit ? AppTheme.surfaceSelected : AppTheme.surfaceMuted)
                                )
                        }
                        .disabled(!canSubmit)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("New In-Person Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onDismiss)
                        .font(AppFont.helvetica(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .onAppear {
                refreshSlots()
            }
        }
    }
    
    private var canSubmit: Bool {
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedSlot != nil
    }
    
    private func refreshSlots() {
        slots = scheduleService.generateSlots(
            for: selectedDate,
            durationMinutes: selectedService.durationMinutes,
            openingHour: 8,
            closingHour: 20,
            appointments: appointments,
            vacations: vacations,
            referenceNow: Calendar.current.isDateInToday(selectedDate) ? Date() : .distantPast
        )
    }
    
    private func submitBooking() {
        errorMessage = nil
        let trimmedName = clientName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter client name."
            return
        }
        
        guard let slot = selectedSlot else {
            errorMessage = "Please choose a time slot."
            return
        }
        
        let newAppt = Appointment(
            date: slot.startTime,
            clientName: trimmedName,
            clientPhone: clientPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "In-Person Walk-in" : clientPhone,
            serviceType: selectedService.name,
            isCancelled: false,
            cancellationReason: nil
        )
        
        modelContext.insert(newAppt)
        try? modelContext.save()
        onDismiss()
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(AppFont.helvetica(size: 11, weight: .bold))
            .tracking(1)
            .foregroundColor(AppTheme.textSecondary)
            .padding(.horizontal, 20)
    }
    
    private func inputField(
        label: String,
        placeholder: String,
        icon: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFont.helvetica(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(width: 20)
                
                TextField(placeholder, text: text)
                    .font(AppFont.helvetica(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ManualBookingSheet(onDismiss: {})
        .modelContainer(for: [Appointment.self, VacationPeriod.self], inMemory: true)
}
