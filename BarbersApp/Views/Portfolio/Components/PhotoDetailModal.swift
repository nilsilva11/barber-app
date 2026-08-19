import SwiftUI

struct PhotoDetailModal: View {
    let item: PortfolioItem
    let onBookCut: (CutCategory) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.canvas.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top drag bar
                Capsule()
                    .fill(AppTheme.borderSubtle)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                
                // High-Resolution Image Container with strict geometric bounds
                Color.clear
                    .frame(height: 380)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        item.renderImage()
                            .scaledToFill()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                
                // Details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.category.displayName.uppercased())
                            .font(AppFont.helvetica(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                    }
                    
                    Text(item.title)
                        .font(AppFont.helvetica(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(item.category.subtitle)
                        .font(AppFont.helvetica(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 10) {
                    Button {
                        onDismiss()
                        onBookCut(item.category)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "scissors")
                                .font(.system(size: 13, weight: .bold))
                            Text("Book This Cut (\(item.category.associatedServiceName))")
                                .font(AppFont.helvetica(size: 14, weight: .bold))
                        }
                        .foregroundColor(AppTheme.textOnSelected)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.surfaceSelected)
                        )
                    }
                    
                    Button("Close", action: onDismiss)
                        .font(AppFont.helvetica(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    let sample = PortfolioItem(
        title: "Low Skin Fade & Textured Crop",
        category: .fade,
        assetName: "fade1"
    )
    
    return PhotoDetailModal(
        item: sample,
        onBookCut: { _ in },
        onDismiss: {}
    )
}
