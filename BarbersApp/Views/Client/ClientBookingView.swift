import SwiftUI
import SwiftData

struct ClientBookingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var vacations: [VacationPeriod]
    
    var preselectedServiceName: String? = nil
    var onOpenAdmin: (() -> Void)? = nil
    
    @State private var viewModel = ClientBookingViewModel()
    @State private var showConfirmationSheet: Bool = false
    @State private var showCalendarGridSheet: Bool = false
    @State private var showAdminLoginSheet: Bool = false
    @State private var authService = AdminAuthService()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                AppTheme.canvas.ignoresSafeArea()
                
                // Main Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // Header Branding (Centered Logo, scrolls with content)
                        VStack(spacing: 16) {
                            HStack {
                                Spacer()
                                Image("BarberLogo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 52, height: 52)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                    )
                                Spacer()
                            }
                            
                            Text("Reserve Your Spot")
                                .font(AppFont.helvetica(size: 26, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // SECTION 1: Service Selection
                        VStack(alignment: .leading, spacing: 14) {
                            sectionHeader(title: "01 / SELECT SERVICE", count: "\(viewModel.availableServices.count) options")
                            
                            VStack(spacing: 10) {
                                ForEach(viewModel.availableServices) { service in
                                    ServiceCardView(
                                        service: service,
                                        isSelected: viewModel.selectedService.id == service.id
                                    ) {
                                        viewModel.selectService(service, appointments: appointments, vacations: vacations)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // SECTION 2: Date Selection (Carousel + Grid Switcher)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("02 / SELECT DATE")
                                    .font(AppFont.helvetica(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Button {
                                    showCalendarGridSheet = true
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text("Calendar Grid")
                                            .font(AppFont.helvetica(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppTheme.surface)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            
                            DateRibbonView(
                                selectedDate: $viewModel.selectedDate,
                                onDateChanged: { newDate in
                                    viewModel.selectDate(newDate, appointments: appointments, vacations: vacations)
                                },
                                isVacationDay: { date in
                                    let scheduleService = ScheduleService()
                                    return scheduleService.isVacation(on: date, vacations: vacations).isVacation
                                }
                            )
                        }
                        
                        // SECTION 3: Time Slot Selection
                        VStack(alignment: .leading, spacing: 14) {
                            let availableCount = viewModel.availableSlots.count
                            sectionHeader(
                                title: "03 / AVAILABLE SPOTS",
                                count: viewModel.isVacationDay ? "Vacation" : "\(availableCount) free"
                            )
                            
                            TimeSlotGridView(
                                slots: viewModel.slots,
                                selectedSlot: viewModel.selectedSlot,
                                isVacationDay: viewModel.isVacationDay,
                                vacationReason: viewModel.vacationReason
                            ) { slot in
                                viewModel.selectSlot(slot)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // SECTION 4: Client Information
                        VStack(alignment: .leading, spacing: 14) {
                            sectionHeader(title: "04 / CONTACT DETAILS", count: "Required")
                            
                            VStack(spacing: 12) {
                                inputField(
                                    label: "Full Name",
                                    placeholder: "e.g. James Peterson",
                                    icon: "person",
                                    text: $viewModel.clientName
                                )
                                
                                inputField(
                                    label: "Phone Number",
                                    placeholder: "e.g. +351 912 345 678",
                                    icon: "phone",
                                    text: $viewModel.clientPhone,
                                    keyboardType: .phonePad
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Error Notice if applicable
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.statusWarning)
                                
                                Text(error)
                                    .font(AppFont.helvetica(size: 12, weight: .regular))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.surfaceMuted)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.statusWarning.opacity(0.4), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Footer with discreet Staff Portal access
                        VStack(spacing: 8) {
                            Divider()
                                .background(AppTheme.borderSubtle.opacity(0.6))
                            
                            HStack {
                                Text("Matos Barbershop • Mon – Sat 09:00 - 19:00")
                                    .font(AppFont.helvetica(size: 11, weight: .regular))
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                Spacer()
                                
                                Button {
                                    showAdminLoginSheet = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 10))
                                        Text("Staff Access")
                                            .font(AppFont.helvetica(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(AppTheme.surface)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Bottom spacing for sticky bar
                        Spacer()
                            .frame(height: 110)
                    }
                }
                
                // Sticky Bottom Booking Bar
                bottomBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.refreshSlots(appointments: appointments, vacations: vacations)
                if let name = preselectedServiceName, let found = viewModel.availableServices.first(where: { $0.name == name }) {
                    viewModel.selectService(found, appointments: appointments, vacations: vacations)
                }
            }
            .onChange(of: preselectedServiceName) { _, newName in
                if let name = newName, let found = viewModel.availableServices.first(where: { $0.name == name }) {
                    viewModel.selectService(found, appointments: appointments, vacations: vacations)
                }
            }
            .onChange(of: appointments) {
                viewModel.refreshSlots(appointments: appointments, vacations: vacations)
            }
            .onChange(of: vacations) {
                viewModel.refreshSlots(appointments: appointments, vacations: vacations)
            }
            .sheet(isPresented: $showCalendarGridSheet) {
                CalendarGridView(
                    selectedDate: $viewModel.selectedDate,
                    onDateSelected: { newDate in
                        viewModel.selectDate(newDate, appointments: appointments, vacations: vacations)
                    },
                    isVacationDay: { date in
                        let scheduleService = ScheduleService()
                        return scheduleService.isVacation(on: date, vacations: vacations).isVacation
                    },
                    onDismiss: {
                        showCalendarGridSheet = false
                    }
                )
                .presentationDetents([.fraction(0.72), .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAdminLoginSheet) {
                AdminLoginSheet(
                    authService: authService,
                    onAuthenticated: {
                        showAdminLoginSheet = false
                        onOpenAdmin?()
                    },
                    onDismiss: {
                        showAdminLoginSheet = false
                    }
                )
                .presentationDetents([.fraction(0.85), .large])
            }
            .sheet(isPresented: $showConfirmationSheet) {
                if let created = viewModel.createdAppointment {
                    BookingConfirmationSheet(appointment: created) {
                        showConfirmationSheet = false
                        viewModel.resetForm()
                        viewModel.refreshSlots(appointments: appointments, vacations: vacations)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func sectionHeader(title: String, count: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.helvetica(size: 11, weight: .bold))
                .tracking(1)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(count)
                .font(AppFont.helvetica(size: 11, weight: .regular))
                .foregroundColor(AppTheme.textTertiary)
        }
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
            .padding(.vertical, 13)
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
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppTheme.borderSubtle)
            
            HStack(alignment: .center, spacing: 12) {
                // Booking Summary snippet
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "Total: €%.0f", viewModel.selectedService.price))
                        .font(AppFont.helvetica(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    if let slot = viewModel.selectedSlot {
                        Text("\(formattedShortDate(viewModel.selectedDate)) at \(slot.formattedStartTime)")
                            .font(AppFont.helvetica(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else {
                        Text("Select a time slot")
                            .font(AppFont.helvetica(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.textTertiary)
                            .lineLimit(1)
                    }
                }
                
                Spacer(minLength: 8)
                
                // Confirm Button
                Button {
                    let success = viewModel.bookAppointment(
                        context: modelContext,
                        appointments: appointments,
                        vacations: vacations
                    )
                    if success {
                        showConfirmationSheet = true
                    }
                } label: {
                    HStack(spacing: 6) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(AppTheme.textOnSelected)
                        } else {
                            Text("Confirm Booking")
                                .font(AppFont.helvetica(size: 14, weight: .bold))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .foregroundColor(AppTheme.textOnSelected)
                    .padding(.horizontal, 18)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.canBook ? AppTheme.surfaceSelected : AppTheme.surfaceMuted)
                    )
                }
                .disabled(!viewModel.canBook || viewModel.isSubmitting)
                .layoutPriority(1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.canvas)
        }
    }
    
    private func formattedShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    let schema = Schema([Appointment.self, VacationPeriod.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = container.mainContext
    
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
    if let tomorrow10 = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: tomorrow) {
        context.insert(
            Appointment(
                date: tomorrow10,
                clientName: "David Miller",
                clientPhone: "+351 919 888 777",
                serviceType: "Classic Haircut"
            )
        )
    }
    
    return ClientBookingView()
        .modelContainer(container)
}
