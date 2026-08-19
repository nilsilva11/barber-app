import SwiftUI
import SwiftData

struct CategoryGalleryView: View {
    let category: CutCategory
    let items: [PortfolioItem]
    let onBookCut: (CutCategory) -> Void
    let onBack: () -> Void
    
    @State private var selectedItem: PortfolioItem? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header with back button & category info
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: onBack) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 13, weight: .bold))
                                Text("All Work")
                                    .font(AppFont.helvetica(size: 13, weight: .medium))
                            }
                            .foregroundColor(AppTheme.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                        
                        Text(category.displayName)
                            .font(AppFont.helvetica(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.top, 4)
                        
                        Text(category.subtitle)
                            .font(AppFont.helvetica(size: 13, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // 2-Column Uniform Gallery Grid (Strict geometrical container clipping)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(items) { item in
                            Button {
                                selectedItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Geometrically locked 1:1 square container
                                    Color.clear
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .overlay(
                                            item.renderImage()
                                                .scaledToFill()
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .clipped()
                                        .contentShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                        )
                                    
                                    Text(item.title)
                                        .font(AppFont.helvetica(size: 12, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .lineLimit(1)
                                        .padding(.horizontal, 4)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppTheme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedItem) { item in
            PhotoDetailModal(
                item: item,
                onBookCut: onBookCut,
                onDismiss: {
                    selectedItem = nil
                }
            )
            .presentationDetents([.fraction(0.85), .large])
        }
    }
}

#Preview {
    let schema = Schema([PortfolioItem.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = container.mainContext
    
    PortfolioItem.seedDefaultItems(context: context)
    let descriptor = FetchDescriptor<PortfolioItem>()
    let items = (try? context.fetch(descriptor))?.filter { $0.category == .fade } ?? []
    
    return CategoryGalleryView(
        category: .fade,
        items: items,
        onBookCut: { _ in },
        onBack: {}
    )
    .modelContainer(container)
}
