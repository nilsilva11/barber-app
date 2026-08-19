import SwiftUI

struct TimeSlotGridView: View {
    let slots: [TimeSlot]
    let selectedSlot: TimeSlot?
    let isVacationDay: Bool
    let vacationReason: String?
    let onSelectSlot: (TimeSlot) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isVacationDay {
                HStack(spacing: 12) {
                    Image(systemName: "sun.haze")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.statusWarning)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Barber Unavailable")
                            .font(AppFont.helvetica(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(vacationReason?.isEmpty == false ? vacationReason! : "Out of office for vacation.")
                            .font(AppFont.helvetica(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.surfaceMuted)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
            } else if slots.isEmpty {
                Text("No available time slots on this date.")
                    .font(AppFont.helvetica(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(slots) { slot in
                        let isSelected = selectedSlot?.id == slot.id
                        
                        Button {
                            if slot.isAvailable {
                                onSelectSlot(slot)
                            }
                        } label: {
                            VStack(spacing: 3) {
                                Text(slot.formattedStartTime)
                                    .font(AppFont.helvetica(size: 14, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(
                                        isSelected
                                            ? AppTheme.textOnSelected
                                            : (slot.isAvailable ? AppTheme.textPrimary : AppTheme.textTertiary)
                                    )
                                
                                if !slot.isAvailable {
                                    Text(slot.unavailableReason ?? "Unavailable")
                                        .font(AppFont.helvetica(size: 10, weight: .regular))
                                        .foregroundColor(AppTheme.textTertiary)
                                        .lineLimit(1)
                                } else {
                                    Text("Available")
                                        .font(AppFont.helvetica(size: 10, weight: .regular))
                                        .foregroundColor(isSelected ? AppTheme.textOnSelected.opacity(0.85) : AppTheme.statusSuccess)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        isSelected
                                            ? AppTheme.surfaceSelected
                                            : (slot.isAvailable ? AppTheme.surface : AppTheme.surfaceMuted.opacity(0.5))
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        isSelected
                                            ? AppTheme.borderActive
                                            : (slot.isAvailable ? AppTheme.borderSubtle : AppTheme.borderSubtle.opacity(0.4)),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!slot.isAvailable)
                    }
                }
            }
        }
    }
}

#Preview("Slots Grid - Normal") {
    @Previewable @State var selectedSlot: TimeSlot? = nil
    
    let now = Date()
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: now)
    
    let sampleSlots: [TimeSlot] = (9...17).map { hour in
        let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay)!
        let end = calendar.date(bySettingHour: hour, minute: 45, second: 0, of: startOfDay)!
        let isBooked = (hour == 11 || hour == 14)
        return TimeSlot(
            startTime: start,
            endTime: end,
            isAvailable: !isBooked,
            unavailableReason: isBooked ? "Booked" : nil
        )
    }
    
    ZStack {
        AppTheme.canvas.ignoresSafeArea()
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Time Slot")
                .font(AppFont.helvetica(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            TimeSlotGridView(
                slots: sampleSlots,
                selectedSlot: selectedSlot,
                isVacationDay: false,
                vacationReason: nil
            ) { slot in
                selectedSlot = slot
            }
        }
        .padding(20)
    }
}

#Preview("Slots Grid - Vacation") {
    ZStack {
        AppTheme.canvas.ignoresSafeArea()
        
        TimeSlotGridView(
            slots: [],
            selectedSlot: nil,
            isVacationDay: true,
            vacationReason: "Summer Break - Resuming on Monday"
        ) { _ in }
        .padding(20)
    }
}
