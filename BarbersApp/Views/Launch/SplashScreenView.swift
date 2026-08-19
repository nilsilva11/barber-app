import SwiftUI

struct SplashScreenView: View {
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.92
    
    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            
            VStack(spacing: 22) {
                Image("BarberLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.borderSubtle, lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
                
                VStack(spacing: 6) {
                    Text("MATOS")
                        .font(AppFont.helvetica(size: 24, weight: .bold))
                        .tracking(5)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("BARBERSHOP")
                        .font(AppFont.helvetica(size: 11, weight: .medium))
                        .tracking(6)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
