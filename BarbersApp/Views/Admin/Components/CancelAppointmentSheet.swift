import SwiftUI

struct CancelAppointmentSheet: View {
    let appointment: Appointment
    @Binding var reasonText: String
    let onConfirmCancel: () -> Void
    let onDismiss: () -> Void
    
    private let presetReasons = [
        "Personal Emergency",
        "Schedule Conflict",
        "Barber Out of Office",
        "Client Requested via Call",
        "Double Booking Adjustment"
    ]
    
    var body: some View {
        VStack(spacing: 22) {
            // Drag Handle
            Capsule()
                .fill(AppTheme.borderSubtle)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
            
            // Header
            VStack(spacing: 6) {
                Text("Cancel Appointment")
                    .font(AppFont.helvetica(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Please specify a reason for cancelling this booking.")
                    .font(AppFont.helvetica(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Appointment Summary Box
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(appointment.clientName)
                        .font(AppFont.helvetica(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(appointment.serviceType) • \(formattedDateTime(appointment.date))")
                        .font(AppFont.helvetica(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
            }
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
            
            // Preset Reason Chips
            VStack(alignment: .leading, spacing: 10) {
                Text("QUICK REASONS")
                    .font(AppFont.helvetica(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundColor(AppTheme.textSecondary)
                
                FlowLayout(spacing: 8) {
                    ForEach(presetReasons, id: \.self) { preset in
                        let isSelected = reasonText == preset
                        Button {
                            reasonText = preset
                        } label: {
                            Text(preset)
                                .font(AppFont.helvetica(size: 12, weight: .medium))
                                .foregroundColor(isSelected ? AppTheme.textOnSelected : AppTheme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? AppTheme.surfaceSelected : AppTheme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? AppTheme.borderActive : AppTheme.borderSubtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Custom Explanation Input
            VStack(alignment: .leading, spacing: 8) {
                Text("EXPLANATION / NOTES")
                    .font(AppFont.helvetica(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundColor(AppTheme.textSecondary)
                
                TextField("Enter explanation for the client...", text: $reasonText, axis: .vertical)
                    .lineLimit(3...4)
                    .font(AppFont.helvetica(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 10) {
                Button(action: onConfirmCancel) {
                    Text("Confirm Cancellation")
                        .font(AppFont.helvetica(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textOnSelected)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.surfaceSelected)
                        )
                }
                
                Button(action: onDismiss) {
                    Text("Keep Appointment")
                        .font(AppFont.helvetica(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(AppTheme.canvas.ignoresSafeArea())
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Simple FlowLayout helper for preset tags
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    @Previewable @State var reason = "Schedule Conflict"
    let sample = Appointment(
        date: Date().addingTimeInterval(3600 * 4),
        clientName: "David Miller",
        clientPhone: "+351 919 888 777",
        serviceType: "Classic Haircut"
    )
    
    return CancelAppointmentSheet(
        appointment: sample,
        reasonText: $reason,
        onConfirmCancel: {},
        onDismiss: {}
    )
}
