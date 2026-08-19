import SwiftUI
import SwiftData

enum ClientTab: String, CaseIterable, Identifiable {
    case book = "Book"
    case work = "Our Work"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .book: return "calendar"
        case .work: return "photo.stack"
        }
    }
}

struct ContentView: View {
    @State private var isShowingSplash: Bool = true
    @State private var isAdminMode: Bool = false
    @State private var selectedTab: ClientTab = .book
    @State private var preselectedServiceName: String? = nil
    
    var body: some View {
        ZStack {
            // Main App Experience
            Group {
                if isAdminMode {
                    AdminDashboardView {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isAdminMode = false
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        // Minimalist Top Tab Bar
                        topTabBar
                            .padding(.vertical, 8)
                            .background(AppTheme.canvas)
                        
                        // Tab Content
                        Group {
                            switch selectedTab {
                            case .book:
                                ClientBookingView(preselectedServiceName: preselectedServiceName) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        isAdminMode = true
                                    }
                                }
                            case .work:
                                PortfolioHubView { serviceName in
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        preselectedServiceName = serviceName
                                        selectedTab = .book
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(AppTheme.canvas.ignoresSafeArea())
                }
            }
            
            // Brand Splash / Loading Screen
            if isShowingSplash {
                SplashScreenView()
                    .transition(.opacity.combined(with: .scale(scale: 1.03)))
                    .zIndex(999)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isShowingSplash = false
                }
            }
        }
    }
    
    private var topTabBar: some View {
        HStack(spacing: 4) {
            ForEach(ClientTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 11, weight: .semibold))
                        Text(tab.rawValue)
                            .font(AppFont.helvetica(size: 12, weight: .bold))
                    }
                    .foregroundColor(isSelected ? AppTheme.textOnSelected : AppTheme.textSecondary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isSelected ? AppTheme.surfaceSelected : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(AppTheme.surface)
        )
        .overlay(
            Capsule()
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    let schema = Schema([Appointment.self, VacationPeriod.self, PortfolioItem.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = container.mainContext
    
    PortfolioItem.seedDefaultItems(context: context)
    
    context.insert(
        Appointment(
            date: Date().addingTimeInterval(3600),
            clientName: "David Miller",
            clientPhone: "+351 919 888 777",
            serviceType: "Classic Haircut"
        )
    )
    
    return ContentView()
        .modelContainer(container)
}
