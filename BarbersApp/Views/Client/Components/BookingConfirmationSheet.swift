import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BookingConfirmationSheet: View {
    let appointment: Appointment
    let onDismiss: () -> Void
    
    @State private var calendarStatus: CalendarStatus = .idle
    @State private var showSettingsAlert: Bool = false
    
    enum CalendarStatus: Equatable {
        case idle
        case adding
        case added
        case error(String)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Notch Handle
            Capsule()
                .fill(AppTheme.borderSubtle)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Success Icon
                    ZStack {
                        Circle()
                            .fill(AppTheme.surfaceMuted)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppTheme.statusSuccess)
                    }
                    .padding(.top, 4)
                    
                    // Title & Subtitle
                    VStack(spacing: 6) {
                        Text("Booking Confirmed")
                            .font(AppFont.helvetica(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Your spot is reserved. We look forward to seeing you.")
                            .font(AppFont.helvetica(size: 13, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Minimalist Receipt Card
                    VStack(spacing: 14) {
                        receiptRow(title: "Service", value: appointment.serviceType)
                        Divider().background(AppTheme.borderSubtle)
                        
                        receiptRow(title: "Date", value: formattedDate(appointment.date))
                        Divider().background(AppTheme.borderSubtle)
                        
                        receiptRow(title: "Time", value: formattedTime(appointment.date))
                        Divider().background(AppTheme.borderSubtle)
                        
                        receiptRow(title: "Client", value: appointment.clientName)
                        Divider().background(AppTheme.borderSubtle)
                        
                        receiptRow(title: "Contact", value: appointment.clientPhone)
                        Divider().background(AppTheme.borderSubtle)
                        
                        receiptRow(title: "Location", value: "Matos Barbershop")
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // 1-Tap Calendar Integration Button
                    calendarActionButton
                        .padding(.horizontal, 20)
                    
                    if case .error(let message) = calendarStatus {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.statusWarning)
                            
                            Text(message)
                                .font(AppFont.helvetica(size: 12, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 16)
            }
            
            // Bottom Done Button
            VStack(spacing: 0) {
                Divider()
                    .background(AppTheme.borderSubtle.opacity(0.6))
                    .padding(.bottom, 12)
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(AppFont.helvetica(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textOnSelected)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.surfaceSelected)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(AppTheme.canvas)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.canvas.ignoresSafeArea())
        .alert("Calendar Access Needed", isPresented: $showSettingsAlert) {
            Button("Settings") {
                #if canImport(UIKit)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable calendar access in Settings to save your barber appointments with automatic reminders.")
        }
    }
    
    // MARK: - Calendar Action Button (1-Tap)
    private var calendarActionButton: some View {
        Button {
            handleAddCalendarTap()
        } label: {
            HStack(spacing: 10) {
                switch calendarStatus {
                case .idle:
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Add to Apple Calendar")
                        .font(AppFont.helvetica(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    
                case .adding:
                    ProgressView()
                        .tint(AppTheme.textPrimary)
                        .scaleEffect(0.85)
                    
                    Text("Adding to Calendar...")
                        .font(AppFont.helvetica(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                case .added:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.statusSuccess)
                    
                    Text("Added to Calendar")
                        .font(AppFont.helvetica(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.statusSuccess)
                    
                case .error:
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Retry Add to Calendar")
                        .font(AppFont.helvetica(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(calendarButtonBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(calendarButtonBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(calendarStatus == .adding || calendarStatus == .added)
        .animation(.easeInOut(duration: 0.25), value: calendarStatus)
    }
    
    private var calendarButtonBackground: Color {
        switch calendarStatus {
        case .added:
            return AppTheme.statusSuccess.opacity(0.12)
        default:
            return AppTheme.surface
        }
    }
    
    private var calendarButtonBorder: Color {
        switch calendarStatus {
        case .added:
            return AppTheme.statusSuccess.opacity(0.35)
        default:
            return AppTheme.borderSubtle
        }
    }
    
    private func handleAddCalendarTap() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        
        calendarStatus = .adding
        
        Task {
            do {
                _ = try await CalendarService.shared.addAppointment(appointment: appointment)
                await MainActor.run {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        self.calendarStatus = .added
                    }
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                }
            } catch CalendarServiceError.permissionDenied {
                await MainActor.run {
                    self.calendarStatus = .error("Calendar access is required to add events.")
                    self.showSettingsAlert = true
                }
            } catch {
                await MainActor.run {
                    self.calendarStatus = .error(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Subviews & Formatters
    private func receiptRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.helvetica(size: 13, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.helvetica(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleAppointment = Appointment(
        date: Date().addingTimeInterval(3600 * 24),
        clientName: "Alexander Wright",
        clientPhone: "+351 912 345 678",
        serviceType: "Hair & Beard Combo"
    )
    
    return BookingConfirmationSheet(appointment: sampleAppointment) {
        // onDismiss action
    }
}
