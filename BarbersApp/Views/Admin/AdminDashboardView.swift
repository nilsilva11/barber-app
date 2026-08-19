import SwiftUI
import SwiftData

struct AdminDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var appointments: [Appointment]
    @Query private var vacations: [VacationPeriod]
    @Query private var portfolioItems: [PortfolioItem]
    
    var onExitAdmin: (() -> Void)? = nil
    
    @State private var viewModel = AdminDashboardViewModel()
    @State private var showCalendarSheet: Bool = false
    @State private var showPortfolioSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.canvas.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header Title & Action Buttons
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("MANAGEMENT CONSOLE")
                                        .font(AppFont.helvetica(size: 11, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text("Barber Agenda")
                                        .font(AppFont.helvetica(size: 26, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                
                                Spacer()
                                
                                // Exit to Client Mode button
                                if let onExit = onExitAdmin {
                                    Button(action: onExit) {
                                        HStack(spacing: 5) {
                                            Image(systemName: "lock.shield")
                                                .font(.system(size: 11, weight: .bold))
                                            Text("Exit Admin")
                                                .font(AppFont.helvetica(size: 11, weight: .bold))
                                        }
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
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
                            }
                            
                            // Action Buttons (In-Person Booking, Vacations & Portfolio)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    Button {
                                        viewModel.showManualBookingSheet = true
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 12, weight: .bold))
                                            Text("In-Person Booking")
                                                .font(AppFont.helvetica(size: 12, weight: .bold))
                                        }
                                        .foregroundColor(AppTheme.textOnSelected)
                                        .padding(.horizontal, 14)
                                        .frame(height: 38)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppTheme.surfaceSelected)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        viewModel.showVacationSheet = true
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "sun.max")
                                                .font(.system(size: 12, weight: .medium))
                                            Text("Vacations (\(vacations.count))")
                                                .font(AppFont.helvetica(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .frame(height: 38)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppTheme.surface)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        showPortfolioSheet = true
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "photo.stack")
                                                .font(.system(size: 12, weight: .medium))
                                            Text("Portfolio (\(portfolioItems.count))")
                                                .font(AppFont.helvetica(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .frame(height: 38)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppTheme.surface)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // SECTION 1: Daily Quick Stats
                        let stats = viewModel.todayStats(appointments: appointments)
                        HStack(spacing: 10) {
                            statCard(title: "Total Today", count: "\(stats.total)", icon: "calendar")
                            statCard(title: "Upcoming", count: "\(stats.upcoming)", icon: "clock")
                            statCard(title: "Cancelled", count: "\(stats.cancelled)", icon: "xmark.circle")
                        }
                        .padding(.horizontal, 20)
                        
                        // SECTION 2: Date Selector Ribbon
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("SELECT DATE")
                                    .font(AppFont.helvetica(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Button {
                                    showCalendarSheet = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 11))
                                        Text("Calendar")
                                            .font(AppFont.helvetica(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(AppTheme.textPrimary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            
                            DateRibbonView(
                                selectedDate: $viewModel.selectedDate,
                                onDateChanged: { _ in },
                                isVacationDay: { date in
                                    let scheduleService = ScheduleService()
                                    return scheduleService.isVacation(on: date, vacations: vacations).isVacation
                                }
                            )
                        }
                        
                        // SECTION 3: Appointment List for the Selected Date
                        let dayAppointments = viewModel.appointments(for: viewModel.selectedDate, from: appointments)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("SCHEDULE FOR \(formattedDayHeader(viewModel.selectedDate).uppercased())")
                                    .font(AppFont.helvetica(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(dayAppointments.count) appointments")
                                    .font(AppFont.helvetica(size: 11, weight: .regular))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            .padding(.horizontal, 20)
                            
                            if dayAppointments.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 32))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    Text("No bookings for this date")
                                        .font(AppFont.helvetica(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("You can manually book an in-person client or take time off.")
                                        .font(AppFont.helvetica(size: 12, weight: .regular))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Button {
                                        viewModel.showManualBookingSheet = true
                                    } label: {
                                        Text("+ In-Person Booking")
                                            .font(AppFont.helvetica(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.textOnSelected)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(AppTheme.surfaceSelected)
                                            )
                                    }
                                    .padding(.top, 4)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppTheme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(dayAppointments) { appointment in
                                        AdminAppointmentCard(appointment: appointment) {
                                            viewModel.prepareCancellation(for: appointment)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.showCancelSheet) {
                if let appt = viewModel.appointmentToCancel {
                    CancelAppointmentSheet(
                        appointment: appt,
                        reasonText: $viewModel.cancellationReasonText,
                        onConfirmCancel: {
                            viewModel.confirmCancellation(context: modelContext)
                        },
                        onDismiss: {
                            viewModel.showCancelSheet = false
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
            .sheet(isPresented: $viewModel.showVacationSheet) {
                VacationManagementSheet {
                    viewModel.showVacationSheet = false
                }
            }
            .sheet(isPresented: $viewModel.showManualBookingSheet) {
                ManualBookingSheet {
                    viewModel.showManualBookingSheet = false
                }
            }
            .sheet(isPresented: $showPortfolioSheet) {
                AdminPortfolioManagementSheet {
                    showPortfolioSheet = false
                }
            }
            .sheet(isPresented: $showCalendarSheet) {
                CalendarGridView(
                    selectedDate: $viewModel.selectedDate,
                    onDateSelected: { _ in },
                    isVacationDay: { date in
                        let scheduleService = ScheduleService()
                        return scheduleService.isVacation(on: date, vacations: vacations).isVacation
                    },
                    onDismiss: {
                        showCalendarSheet = false
                    }
                )
                .presentationDetents([.fraction(0.72), .large])
            }
        }
    }
    
    // MARK: - Subviews & Helpers
    
    private func statCard(title: String, count: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(AppFont.helvetica(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            Text(count)
                .font(AppFont.helvetica(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }
    
    private func formattedDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    let schema = Schema([Appointment.self, VacationPeriod.self, PortfolioItem.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = container.mainContext
    
    let now = Date()
    context.insert(
        Appointment(
            date: now.addingTimeInterval(1800),
            clientName: "David Miller",
            clientPhone: "+351 919 888 777",
            serviceType: "Classic Haircut"
        )
    )
    context.insert(
        Appointment(
            date: now.addingTimeInterval(5400),
            clientName: "Alexandre Santos",
            clientPhone: "+351 922 333 444",
            serviceType: "Hair & Beard Combo"
        )
    )
    
    return AdminDashboardView(onExitAdmin: {})
        .modelContainer(container)
}
