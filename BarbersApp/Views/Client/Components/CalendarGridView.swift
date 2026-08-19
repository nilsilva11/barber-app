import SwiftUI

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    let isVacationDay: (Date) -> Bool
    let onDismiss: () -> Void
    
    @State private var currentMonth: Date
    
    private let calendar = Calendar.current
    private let today: Date
    private let maxDate: Date
    
    init(
        selectedDate: Binding<Date>,
        onDateSelected: @escaping (Date) -> Void,
        isVacationDay: @escaping (Date) -> Bool,
        onDismiss: @escaping () -> Void
    ) {
        self._selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        self.isVacationDay = isVacationDay
        self.onDismiss = onDismiss
        
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        self.today = startOfToday
        self.maxDate = cal.date(byAdding: .day, value: 30, to: startOfToday) ?? startOfToday
        self._currentMonth = State(initialValue: cal.date(from: cal.dateComponents([.year, .month], from: selectedDate.wrappedValue)) ?? startOfToday)
    }
    
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    
    var body: some View {
        VStack(spacing: 20) {
            // Drag indicator handle
            Capsule()
                .fill(AppTheme.borderSubtle)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
            
            // Header: Month Navigation & Title
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SELECT DATE")
                        .font(AppFont.helvetica(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(monthYearTitle(from: currentMonth))
                        .font(AppFont.helvetica(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                // Month Switcher Buttons
                HStack(spacing: 8) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(canGoPreviousMonth ? AppTheme.textPrimary : AppTheme.textTertiary.opacity(0.4))
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                    }
                    .disabled(!canGoPreviousMonth)
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(canGoNextMonth ? AppTheme.textPrimary : AppTheme.textTertiary.opacity(0.4))
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                    }
                    .disabled(!canGoNextMonth)
                }
            }
            .padding(.horizontal, 22)
            
            // Weekday Header
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdays[index])
                        .font(AppFont.helvetica(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 18)
            
            // Days Matrix
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInCurrentMonth()) { dayItem in
                    if let date = dayItem.date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isTodayDate = calendar.isDate(date, inSameDayAs: today)
                        let isWithinBookingWindow = date >= today && date <= maxDate
                        let isVacation = isVacationDay(date)
                        let isAvailable = isWithinBookingWindow && !isVacation
                        
                        Button {
                            if isAvailable {
                                selectedDate = date
                                onDateSelected(date)
                                onDismiss()
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(AppFont.helvetica(size: 14, weight: isSelected ? .bold : (isTodayDate ? .bold : .regular)))
                                    .foregroundColor(
                                        isSelected
                                            ? AppTheme.textOnSelected
                                            : (isAvailable ? AppTheme.textPrimary : AppTheme.textTertiary.opacity(0.35))
                                    )
                                
                                if isVacation {
                                    Circle()
                                        .fill(isSelected ? AppTheme.textOnSelected : AppTheme.statusWarning)
                                        .frame(width: 3.5, height: 3.5)
                                } else if isTodayDate && !isSelected {
                                    Circle()
                                        .fill(AppTheme.textSecondary)
                                        .frame(width: 3.5, height: 3.5)
                                } else {
                                    Spacer()
                                        .frame(height: 3.5)
                                }
                            }
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        isSelected
                                            ? AppTheme.surfaceSelected
                                            : (isAvailable ? AppTheme.surface : Color.clear)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        isSelected
                                            ? AppTheme.borderActive
                                            : (isAvailable ? AppTheme.borderSubtle : Color.clear),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!isAvailable)
                    } else {
                        // Empty padding cell
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 18)
            
            // Legend & 30-day Policy Notice
            VStack(spacing: 12) {
                Divider()
                    .background(AppTheme.borderSubtle)
                
                HStack(spacing: 16) {
                    legendItem(color: AppTheme.surfaceSelected, label: "Selected")
                    legendItem(color: AppTheme.statusWarning, label: "Vacation")
                    legendItem(color: AppTheme.textTertiary.opacity(0.35), label: "Blocked (> 30 days / past)")
                }
                .font(AppFont.helvetica(size: 10, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
                
                Text("• Bookings are available up to 30 days in advance.")
                    .font(AppFont.helvetica(size: 11, weight: .regular))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
            
            Spacer()
        }
        .background(AppTheme.canvas.ignoresSafeArea())
    }
    
    // MARK: - Subviews & Helpers
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
        }
    }
    
    private var canGoPreviousMonth: Bool {
        let startOfCurrent = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) ?? currentMonth
        let startOfTodayMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        return startOfCurrent > startOfTodayMonth
    }
    
    private var canGoNextMonth: Bool {
        let startOfNext = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        let startOfMaxMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: maxDate)) ?? maxDate
        return startOfNext <= startOfMaxMonth
    }
    
    private func previousMonth() {
        guard canGoPreviousMonth else { return }
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        guard canGoNextMonth else { return }
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearTitle(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private struct DayItem: Identifiable {
        let id = UUID()
        let date: Date?
    }
    
    private func daysInCurrentMonth() -> [DayItem] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let weekdayOfFirst = (calendar.component(.weekday, from: firstDay) + 5) % 7 // Monday = 0
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
        
        var items: [DayItem] = []
        
        // Leading blank cells
        for _ in 0..<weekdayOfFirst {
            items.append(DayItem(date: nil))
        }
        
        // Month days
        for day in 1...numberOfDays {
            if let dayDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)!) {
                items.append(DayItem(date: dayDate))
            }
        }
        
        return items
    }
}

#Preview {
    @Previewable @State var selected = Date()
    let calendar = Calendar.current
    let vacationDate = calendar.date(byAdding: .day, value: 5, to: Date())!
    
    CalendarGridView(
        selectedDate: $selected,
        onDateSelected: { _ in },
        isVacationDay: { date in
            calendar.isDate(date, inSameDayAs: vacationDate)
        },
        onDismiss: {}
    )
}
