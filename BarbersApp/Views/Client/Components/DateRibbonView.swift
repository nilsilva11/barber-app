import SwiftUI

struct DateRibbonView: View {
    @Binding var selectedDate: Date
    let onDateChanged: (Date) -> Void
    let isVacationDay: (Date) -> Bool
    
    private let calendar = Calendar.current
    private let daysToShow = 31 // 30 days ahead from today (day 0 to day 30)
    
    private var dates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<daysToShow).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dates, id: \.self) { date in
                        let startOfDate = calendar.startOfDay(for: date)
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isVacation = isVacationDay(date)
                        
                        Button {
                            selectedDate = date
                            onDateChanged(date)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                proxy.scrollTo(startOfDate, anchor: .center)
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(weekdayString(from: date))
                                    .font(AppFont.helvetica(size: 11, weight: .medium))
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                    .foregroundColor(isSelected ? AppTheme.textOnSelected : AppTheme.textSecondary)
                                
                                Text(dayNumberString(from: date))
                                    .font(AppFont.helvetica(size: 18, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? AppTheme.textOnSelected : AppTheme.textPrimary)
                                
                                Text(monthString(from: date))
                                    .font(AppFont.helvetica(size: 10, weight: .regular))
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                    .foregroundColor(isSelected ? AppTheme.textOnSelected.opacity(0.8) : AppTheme.textTertiary)
                                
                                if isVacation {
                                    Circle()
                                        .fill(isSelected ? AppTheme.textOnSelected : AppTheme.statusWarning)
                                        .frame(width: 4, height: 4)
                                } else {
                                    Spacer()
                                        .frame(height: 4)
                                }
                            }
                            .frame(width: 58, height: 86)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? AppTheme.surfaceSelected : AppTheme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? AppTheme.borderActive : AppTheme.borderSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .id(startOfDate)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            .onAppear {
                let startOfSelected = calendar.startOfDay(for: selectedDate)
                proxy.scrollTo(startOfSelected, anchor: .center)
            }
            .onChange(of: selectedDate) { _, newDate in
                let startOfNewDate = calendar.startOfDay(for: newDate)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    proxy.scrollTo(startOfNewDate, anchor: .center)
                }
            }
        }
    }
    
    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func dayNumberString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    let calendar = Calendar.current
    let vacationDate = calendar.date(byAdding: .day, value: 3, to: calendar.startOfDay(for: Date()))!
    
    ZStack {
        AppTheme.canvas.ignoresSafeArea()
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Date Ribbon Preview")
                .font(AppFont.helvetica(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            DateRibbonView(
                selectedDate: $selectedDate,
                onDateChanged: { _ in },
                isVacationDay: { date in
                    calendar.isDate(date, inSameDayAs: vacationDate)
                }
            )
        }
    }
}
