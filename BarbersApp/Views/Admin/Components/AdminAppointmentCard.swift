import SwiftUI

struct AdminAppointmentCard: View {
    let appointment: Appointment
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Row: Time, Status Badge & Service
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Text(formattedTime(appointment.date))
                        .font(AppFont.helvetica(size: 16, weight: .bold))
                        .foregroundColor(appointment.isCancelled ? AppTheme.textTertiary : AppTheme.textPrimary)
                    
                    Text("•")
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text(appointment.serviceType)
                        .font(AppFont.helvetica(size: 13, weight: .medium))
                        .foregroundColor(appointment.isCancelled ? AppTheme.textTertiary : AppTheme.textSecondary)
                }
                
                Spacer()
                
                statusBadge
            }
            
            Divider()
                .background(AppTheme.borderSubtle)
            
            // Bottom Row: Client info & Actions
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(appointment.clientName)
                        .font(AppFont.helvetica(size: 15, weight: .bold))
                        .foregroundColor(appointment.isCancelled ? AppTheme.textTertiary : AppTheme.textPrimary)
                    
                    if !appointment.clientPhone.isEmpty {
                        Text(appointment.clientPhone)
                            .font(AppFont.helvetica(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                if !appointment.isCancelled {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(AppFont.helvetica(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.statusWarning)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.surfaceMuted)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // If cancelled, show explanation reason box
            if appointment.isCancelled, let reason = appointment.cancellationReason, !reason.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                        .padding(.top, 1)
                    
                    Text("Reason: \(reason)")
                        .font(AppFont.helvetica(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.surfaceMuted.opacity(0.6))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(appointment.isCancelled ? AppTheme.surface.opacity(0.6) : AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }
    
    private var statusBadge: some View {
        Group {
            if appointment.isCancelled {
                Text("Cancelled")
                    .font(AppFont.helvetica(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.statusWarning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppTheme.surfaceMuted)
                    )
            } else if appointment.date < Date() {
                Text("Completed")
                    .font(AppFont.helvetica(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppTheme.surfaceMuted)
                    )
            } else {
                Text("Confirmed")
                    .font(AppFont.helvetica(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.statusSuccess)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppTheme.surfaceMuted)
                    )
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    let activeAppt = Appointment(
        date: Date().addingTimeInterval(1800),
        clientName: "Marcus Vance",
        clientPhone: "+351 912 345 678",
        serviceType: "Hair & Beard Combo"
    )
    
    let cancelledAppt = Appointment(
        date: Date().addingTimeInterval(7200),
        clientName: "Lucas Grey",
        clientPhone: "+351 933 111 222",
        serviceType: "Classic Haircut",
        isCancelled: true,
        cancellationReason: "Barber had an unexpected emergency"
    )
    
    return ZStack {
        AppTheme.canvas.ignoresSafeArea()
        
        VStack(spacing: 14) {
            AdminAppointmentCard(appointment: activeAppt) {}
            AdminAppointmentCard(appointment: cancelledAppt) {}
        }
        .padding(20)
    }
}
