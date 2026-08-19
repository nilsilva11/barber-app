import SwiftUI
import SwiftData

struct PortfolioHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var portfolioItems: [PortfolioItem]
    
    let onBookService: (String) -> Void
    
    @State private var activeCategory: CutCategory? = nil
    
    // Default Studio Details
    private let studioPhone = "+351 912 345 678"
    private let phoneUrl = "tel://+351912345678"
    private let instagramHandle = "@matos8arbershop"
    private let instagramUrl = "https://www.instagram.com/matos8arbershop/"
    private let studioAddress = "Rua Garrett 42, Chiado, Lisboa"
    private let mapsUrl = "http://maps.apple.com/?q=Rua+Garrett+42+Lisboa"
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.canvas.ignoresSafeArea()
                
                if let category = activeCategory {
                    let items = portfolioItems.filter { $0.category == category }
                    CategoryGalleryView(
                        category: category,
                        items: items,
                        onBookCut: { cat in
                            onBookService(cat.associatedServiceName)
                        },
                        onBack: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                activeCategory = nil
                            }
                        }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            
                            // Header Branding (Matching Client View style)
                            VStack(spacing: 16) {
                                HStack {
                                    Spacer()
                                    Image("BarberLogo")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 52, height: 52)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                        )
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("THE STUDIO & WORK")
                                        .font(AppFont.helvetica(size: 11, weight: .bold))
                                        .tracking(2.5)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text("Craft & Atmosphere")
                                        .font(AppFont.helvetica(size: 26, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // SECTION 1: Haircut Collections
                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader(title: "01 / CUT COLLECTIONS", count: "2 Styles")
                                
                                let classicCount = portfolioItems.filter { $0.category == .classic }.count
                                categoryCoverCard(
                                    category: .classic,
                                    count: classicCount
                                )
                                
                                let fadeCount = portfolioItems.filter { $0.category == .fade }.count
                                categoryCoverCard(
                                    category: .fade,
                                    count: fadeCount
                                )
                            }
                            
                            // SECTION 2: Studio & About Us
                            VStack(alignment: .leading, spacing: 14) {
                                sectionHeader(title: "02 / ABOUT THE STUDIO", count: "Lisboa")
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    // Studio Interior Hero Image
                                    Color.clear
                                        .frame(height: 220)
                                        .frame(maxWidth: .infinity)
                                        .overlay(
                                            Image("about")
                                                .resizable()
                                                .scaledToFill(),
                                            alignment: .center
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .clipped()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                        )
                                    
                                    // Studio Mission Statement
                                    Text("Crafting precision cuts and timeless styles with dedication to detail, authentic scissor work, and personalized grooming tailored to each individual client.")
                                        .font(AppFont.helvetica(size: 13, weight: .regular))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .lineSpacing(4)
                                    
                                    Divider()
                                        .background(AppTheme.borderSubtle)
                                    
                                    // Quick Interactive Contact Buttons
                                    HStack(spacing: 8) {
                                        actionButton(icon: "phone.fill", label: "Call Shop") {
                                            if let url = URL(string: phoneUrl) { openURL(url) }
                                        }
                                        
                                        instagramActionButton(label: "Instagram") {
                                            if let url = URL(string: instagramUrl) { openURL(url) }
                                        }
                                        
                                        actionButton(icon: "map.fill", label: "Directions") {
                                            if let url = URL(string: mapsUrl) { openURL(url) }
                                        }
                                    }
                                    
                                    Divider()
                                        .background(AppTheme.borderSubtle)
                                    
                                    // Info Rows
                                    VStack(spacing: 10) {
                                        infoRow(icon: "mappin.and.ellipse", title: "Address", value: studioAddress)
                                        infoRow(icon: "phone", title: "Phone", value: studioPhone)
                                        instagramInfoRow(title: "Social", value: instagramHandle)
                                        infoRow(icon: "clock", title: "Hours", value: "Mon – Sat • 09:00 – 19:00")
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppTheme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                PortfolioItem.seedDefaultItems(context: modelContext)
            }
        }
    }
    
    // MARK: - Subviews & Helpers
    
    private func sectionHeader(title: String, count: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.helvetica(size: 11, weight: .bold))
                .tracking(1)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(count)
                .font(AppFont.helvetica(size: 11, weight: .regular))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(.horizontal, 20)
    }
    
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(AppFont.helvetica(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.surfaceMuted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func instagramActionButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                InstagramVectorIcon(size: 12, color: AppTheme.textPrimary)
                Text(label)
                    .font(AppFont.helvetica(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.surfaceMuted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 18)
            
            Text(title)
                .font(AppFont.helvetica(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.helvetica(size: 12, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
    
    private func instagramInfoRow(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            InstagramVectorIcon(size: 13, color: AppTheme.textSecondary)
                .frame(width: 18)
            
            Text(title)
                .font(AppFont.helvetica(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.helvetica(size: 12, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
    
    private func categoryCoverCard(category: CutCategory, count: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                activeCategory = category
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Cover Image (Constrained to exact frame with strict clipping and hit-shape)
                Image(category.coverAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .contentShape(Rectangle())
                    .overlay(
                        // Discreet badge
                        HStack {
                            Spacer()
                            VStack {
                                Text("\(count) Cuts")
                                    .font(AppFont.helvetica(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.textOnSelected)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(AppTheme.surfaceSelected.opacity(0.85))
                                    )
                                Spacer()
                            }
                            .padding(12)
                        }
                    )
                
                // Text Description
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(category.displayName)
                            .font(AppFont.helvetica(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Text(category.subtitle)
                        .font(AppFont.helvetica(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surface)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .id(category.id)
        .padding(.horizontal, 20)
    }
}

// MARK: - Bespoke Instagram Vector Icon
struct InstagramVectorIcon: View {
    var size: CGFloat = 13
    var color: Color = Color(AppTheme.textPrimary)
    
    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let strokeWidth: CGFloat = 1.3
            
            // Outer Rounded Square
            let rect = CGRect(x: strokeWidth / 2, y: strokeWidth / 2, width: w - strokeWidth, height: h - strokeWidth)
            let outerPath = Path(roundedRect: rect, cornerRadius: w * 0.28)
            context.stroke(outerPath, with: .color(color), lineWidth: strokeWidth)
            
            // Center Lens (Circle)
            let lensRect = CGRect(x: w * 0.28, y: h * 0.28, width: w * 0.44, height: h * 0.44)
            let lensPath = Path(ellipseIn: lensRect)
            context.stroke(lensPath, with: .color(color), lineWidth: strokeWidth)
            
            // Flash Dot (Top Right)
            let dotRect = CGRect(x: w * 0.72, y: h * 0.20, width: w * 0.10, height: h * 0.10)
            let dotPath = Path(ellipseIn: dotRect)
            context.fill(dotPath, with: .color(color))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    let schema = Schema([PortfolioItem.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = container.mainContext
    
    PortfolioItem.seedDefaultItems(context: context)
    
    return PortfolioHubView(onBookService: { _ in })
        .modelContainer(container)
}

