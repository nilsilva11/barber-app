import SwiftUI

struct ServiceIconView: View {
    let iconName: String
    let isSelected: Bool
    
    var body: some View {
        Group {
            if iconName == "scissors+mustache" || iconName == "hair+beard" {
                // Bespoke composite icon for Hair & Beard Combo
                ZStack {
                    Image(systemName: "scissors")
                        .font(.system(size: 13, weight: .medium))
                        .rotationEffect(.degrees(-20))
                        .offset(x: -6, y: -6)
                    
                    Image(systemName: "mustache.fill")
                        .font(.system(size: 14, weight: .regular))
                        .offset(x: 5, y: 6)
                }
            } else if iconName == "clipper" || iconName == "clippers" {
                // Bespoke Barber Clipper Icon for Fade Haircuts
                ClipperIconView(isSelected: isSelected)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .regular))
            }
        }
        .foregroundColor(isSelected ? AppTheme.textOnSelected : AppTheme.textPrimary)
    }
}

// MARK: - Vector Clipper Icon
struct ClipperIconView: View {
    let isSelected: Bool
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let color = isSelected ? Color(AppTheme.textOnSelected) : Color(AppTheme.textPrimary)
            
            // Clipper Body (Ergonomic Taper)
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: w * 0.28, y: h * 0.28))
            bodyPath.addLine(to: CGPoint(x: w * 0.72, y: h * 0.28))
            bodyPath.addLine(to: CGPoint(x: w * 0.66, y: h * 0.82))
            bodyPath.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.82), control: CGPoint(x: w * 0.5, y: h * 0.90))
            bodyPath.addLine(to: CGPoint(x: w * 0.28, y: h * 0.28))
            bodyPath.closeSubpath()
            
            context.stroke(bodyPath, with: .color(color), lineWidth: 1.5)
            
            // Blade Base Line
            var bladeBar = Path()
            bladeBar.move(to: CGPoint(x: w * 0.22, y: h * 0.26))
            bladeBar.addLine(to: CGPoint(x: w * 0.78, y: h * 0.26))
            context.stroke(bladeBar, with: .color(color), lineWidth: 1.5)
            
            // Blade Tines / Teeth
            let teethCount = 6
            var teethPath = Path()
            for i in 0..<teethCount {
                let x = w * 0.25 + (CGFloat(i) / CGFloat(teethCount - 1)) * (w * 0.50)
                teethPath.move(to: CGPoint(x: x, y: h * 0.26))
                teethPath.addLine(to: CGPoint(x: x, y: h * 0.12))
            }
            context.stroke(teethPath, with: .color(color), lineWidth: 1.4)
            
            // Power / Taper Lever Detail
            var leverPath = Path()
            leverPath.move(to: CGPoint(x: w * 0.40, y: h * 0.50))
            leverPath.addLine(to: CGPoint(x: w * 0.60, y: h * 0.50))
            context.stroke(leverPath, with: .color(color), lineWidth: 1.3)
        }
        .frame(width: 22, height: 22)
    }
}

#Preview {
    ZStack {
        AppTheme.canvas.ignoresSafeArea()
        
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.surfaceMuted)
                            .frame(width: 48, height: 48)
                        
                        ServiceIconView(iconName: "clipper", isSelected: false)
                    }
                    Text("Clipper Unselected")
                        .font(AppFont.helvetica(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.surfaceSelected)
                            .frame(width: 48, height: 48)
                        
                        ServiceIconView(iconName: "clipper", isSelected: true)
                    }
                    Text("Clipper Selected")
                        .font(AppFont.helvetica(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.surfaceMuted)
                            .frame(width: 48, height: 48)
                        
                        ServiceIconView(iconName: "scissors+mustache", isSelected: false)
                    }
                    Text("Combo")
                        .font(AppFont.helvetica(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding()
    }
}
