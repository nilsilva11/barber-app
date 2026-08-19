import SwiftUI

struct ServiceCardView: View {
    let service: BarberService
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 14) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? AppTheme.surfaceSelected : AppTheme.surfaceMuted)
                        .frame(width: 44, height: 44)
                    
                    ServiceIconView(iconName: service.iconName, isSelected: isSelected)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 3) {
                    Text(service.name)
                        .font(AppFont.helvetica(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(service.description)
                        .font(AppFont.helvetica(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Pricing & Duration
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "€%.0f", service.price))
                        .font(AppFont.helvetica(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(service.durationMinutes) min")
                        .font(AppFont.helvetica(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppTheme.borderActive : AppTheme.borderSubtle, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedId = "hair-beard-combo"
    
    ZStack {
        AppTheme.canvas.ignoresSafeArea()
        
        VStack(spacing: 12) {
            ForEach(BarberService.sampleServices) { service in
                ServiceCardView(
                    service: service,
                    isSelected: selectedId == service.id
                ) {
                    selectedId = service.id
                }
            }
        }
        .padding(20)
    }
}
