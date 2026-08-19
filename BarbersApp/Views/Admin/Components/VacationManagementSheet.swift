import SwiftUI
import SwiftData

struct VacationManagementSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var vacations: [VacationPeriod]
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600 * 24 * 4)
    @State private var reason: String = ""
    @State private var isAdding: Bool = false
    
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.canvas.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // SECTION 1: Add New Vacation Form
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SET VACATION / BLACKOUT")
                                .font(AppFont.helvetica(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            VStack(spacing: 14) {
                                DatePicker(
                                    "Start Date",
                                    selection: $startDate,
                                    displayedComponents: [.date]
                                )
                                .font(AppFont.helvetica(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .tint(AppTheme.surfaceSelected)
                                
                                Divider().background(AppTheme.borderSubtle)
                                
                                DatePicker(
                                    "End Date",
                                    selection: $endDate,
                                    in: startDate...,
                                    displayedComponents: [.date]
                                )
                                .font(AppFont.helvetica(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .tint(AppTheme.surfaceSelected)
                                
                                Divider().background(AppTheme.borderSubtle)
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    TextField("Reason (e.g. Summer Holiday)", text: $reason)
                                        .font(AppFont.helvetica(size: 13, weight: .regular))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                            
                            Button {
                                addVacationPeriod()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Add Vacation Period")
                                        .font(AppFont.helvetica(size: 14, weight: .bold))
                                }
                                .foregroundColor(AppTheme.textOnSelected)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.surfaceSelected)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // SECTION 2: Active & Scheduled Vacations
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SCHEDULED VACATION PERIODS")
                                .font(AppFont.helvetica(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            if vacations.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 6) {
                                        Image(systemName: "sun.max")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppTheme.textTertiary)
                                        Text("No vacation periods scheduled.")
                                            .font(AppFont.helvetica(size: 13, weight: .regular))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    .padding(.vertical, 24)
                                    Spacer()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                )
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(vacations) { vacation in
                                        HStack(alignment: .center, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(vacation.reason?.isEmpty == false ? vacation.reason! : "Barber Vacation")
                                                    .font(AppFont.helvetica(size: 14, weight: .bold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                
                                                Text("\(formatDate(vacation.startDate)) — \(formatDate(vacation.endDate))")
                                                    .font(AppFont.helvetica(size: 12, weight: .regular))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Button {
                                                deleteVacation(vacation)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(AppTheme.statusWarning)
                                                    .padding(8)
                                                    .background(
                                                        Circle()
                                                            .fill(AppTheme.surfaceMuted)
                                                    )
                                            }
                                            .buttonStyle(.plain)
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
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationTitle("Vacation Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                        .font(AppFont.helvetica(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
    }
    
    private func addVacationPeriod() {
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let newVacation = VacationPeriod(
            startDate: Calendar.current.startOfDay(for: startDate),
            endDate: Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate,
            reason: trimmedReason.isEmpty ? "Vacation" : trimmedReason
        )
        modelContext.insert(newVacation)
        try? modelContext.save()
        
        reason = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(3600 * 24 * 4)
    }
    
    private func deleteVacation(_ vacation: VacationPeriod) {
        modelContext.delete(vacation)
        try? modelContext.save()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    let schema = Schema([VacationPeriod.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = container.mainContext
    
    context.insert(
        VacationPeriod(
            startDate: Date().addingTimeInterval(3600 * 24 * 2),
            endDate: Date().addingTimeInterval(3600 * 24 * 6),
            reason: "Summer Break"
        )
    )
    
    return VacationManagementSheet(onDismiss: {})
        .modelContainer(container)
}
