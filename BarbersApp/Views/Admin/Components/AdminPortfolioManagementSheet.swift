import SwiftUI
import SwiftData
import PhotosUI

struct AdminPortfolioManagementSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var portfolioItems: [PortfolioItem]
    
    let onDismiss: () -> Void
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var newTitle: String = ""
    @State private var newCategory: CutCategory = .fade
    @State private var isUploading: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.canvas.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // SECTION 1: Add Photo Form
                        VStack(alignment: .leading, spacing: 14) {
                            Text("ADD NEW WORK TO PORTFOLIO")
                                .font(AppFont.helvetica(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            VStack(spacing: 14) {
                                // Photo Picker Box
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                        Color.clear
                                            .frame(height: 160)
                                            .frame(maxWidth: .infinity)
                                            .overlay(
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .clipped()
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.system(size: 24))
                                                .foregroundColor(AppTheme.textSecondary)
                                            Text("Select Photo from Camera Roll")
                                                .font(AppFont.helvetica(size: 13, weight: .medium))
                                                .foregroundColor(AppTheme.textPrimary)
                                        }
                                        .frame(height: 120)
                                        .frame(maxWidth: .infinity)
                                        .background(AppTheme.surfaceMuted)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                .buttonStyle(.plain)
                                .onChange(of: selectedPhotoItem) {
                                    Task {
                                        if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                            selectedImageData = data
                                        }
                                    }
                                }
                                
                                // Category Picker
                                Picker("Category", selection: $newCategory) {
                                    ForEach(CutCategory.allCases) { cat in
                                        Text(cat.displayName).tag(cat)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                // Title Field
                                HStack(spacing: 10) {
                                    Image(systemName: "tag")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textTertiary)
                                    TextField("Cut Title (e.g. Mid Taper Fade)", text: $newTitle)
                                        .font(AppFont.helvetica(size: 13, weight: .regular))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(AppTheme.surfaceMuted)
                                )
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
                                addPortfolioItem()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add to Portfolio")
                                        .font(AppFont.helvetica(size: 14, weight: .bold))
                                }
                                .foregroundColor(AppTheme.textOnSelected)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(canSubmit ? AppTheme.surfaceSelected : AppTheme.surfaceMuted)
                                )
                            }
                            .disabled(!canSubmit)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // SECTION 2: Existing Portfolio Items
                        VStack(alignment: .leading, spacing: 14) {
                            Text("CURRENT PORTFOLIO PHOTOS (\(portfolioItems.count))")
                                .font(AppFont.helvetica(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            VStack(spacing: 10) {
                                ForEach(portfolioItems) { item in
                                    HStack(spacing: 12) {
                                        Color.clear
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                item.renderImage()
                                                    .scaledToFill()
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .clipped()
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.title)
                                                .font(AppFont.helvetica(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Text(item.category.displayName)
                                                .font(AppFont.helvetica(size: 11, weight: .regular))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            deleteItem(item)
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppTheme.statusWarning)
                                                .padding(8)
                                                .background(
                                                    Circle()
                                                        .fill(AppTheme.surfaceMuted)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(12)
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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Manage Portfolio")
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
    
    private var canSubmit: Bool {
        selectedImageData != nil && !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addPortfolioItem() {
        guard let data = selectedImageData else { return }
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let newItem = PortfolioItem(
            title: title,
            category: newCategory,
            customImageData: data
        )
        modelContext.insert(newItem)
        try? modelContext.save()
        
        // Reset form
        selectedPhotoItem = nil
        selectedImageData = nil
        newTitle = ""
    }
    
    private func deleteItem(_ item: PortfolioItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

#Preview {
    AdminPortfolioManagementSheet(onDismiss: {})
        .modelContainer(for: [PortfolioItem.self], inMemory: true)
}
