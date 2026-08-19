import SwiftUI

struct AdminLoginSheet: View {
    let authService: AdminAuthService
    let onAuthenticated: () -> Void
    let onDismiss: () -> Void
    
    @State private var pin: String = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var showErrorText: Bool = false
    
    private let pinLength = 4
    
    var body: some View {
        VStack(spacing: 28) {
            // Drag Handle
            Capsule()
                .fill(AppTheme.borderSubtle)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
            
            // Header with Logo
            VStack(spacing: 12) {
                Image("BarberLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                    )
                
                VStack(spacing: 4) {
                    Text("STAFF PORTAL")
                        .font(AppFont.helvetica(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Enter Admin PIN")
                        .font(AppFont.helvetica(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                
                }
            }
            .padding(.top, 4)
            
            // PIN Dots Indicator with Shake Effect
            HStack(spacing: 16) {
                ForEach(0..<pinLength, id: \.self) { index in
                    Circle()
                        .fill(index < pin.count ? AppTheme.surfaceSelected : AppTheme.surfaceMuted)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.borderSubtle, lineWidth: 1)
                        )
                }
            }
            .offset(x: shakeOffset)
            .padding(.vertical, 8)
            
            if showErrorText {
                Text("Incorrect PIN code. Try again.")
                    .font(AppFont.helvetica(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.statusWarning)
            } else {
                Spacer()
                    .frame(height: 18)
            }
            
            // Custom Numeric Keypad
            VStack(spacing: 14) {
                keypadRow(["1", "2", "3"])
                keypadRow(["4", "5", "6"])
                keypadRow(["7", "8", "9"])
                
                // Bottom row: Biometrics / Empty, "0", "Delete"
                HStack(spacing: 24) {
                    if authService.isBiometricsAvailable {
                        Button(action: triggerBiometrics) {
                            Image(systemName: "faceid")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(width: 68, height: 68)
                                .background(
                                    Circle()
                                        .fill(AppTheme.surface)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Spacer()
                            .frame(width: 68, height: 68)
                    }
                    
                    keypadButton("0")
                    
                    Button(action: deleteDigit) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 68, height: 68)
                            .background(
                                Circle()
                                    .fill(AppTheme.surface)
                            )
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(pin.isEmpty)
                    .opacity(pin.isEmpty ? 0.3 : 1.0)
                }
            }
            
            Spacer()
            
            // Cancel / Dismiss Button
            Button("Cancel", action: onDismiss)
                .font(AppFont.helvetica(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.canvas.ignoresSafeArea())
    }
    
    // MARK: - Subviews & Actions
    
    private func keypadRow(_ keys: [String]) -> some View {
        HStack(spacing: 24) {
            ForEach(keys, id: \.self) { key in
                keypadButton(key)
            }
        }
    }
    
    private func keypadButton(_ digit: String) -> some View {
        Button {
            appendDigit(digit)
        } label: {
            Text(digit)
                .font(AppFont.helvetica(size: 22, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(AppTheme.surface)
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func appendDigit(_ digit: String) {
        guard pin.count < pinLength else { return }
        showErrorText = false
        pin.append(digit)
        
        if pin.count == pinLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if authService.verifyPIN(pin) {
                    onAuthenticated()
                } else {
                    triggerShake()
                }
            }
        }
    }
    
    private func deleteDigit() {
        if !pin.isEmpty {
            pin.removeLast()
            showErrorText = false
        }
    }
    
    private func triggerShake() {
        showErrorText = true
        withAnimation(.default) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.default) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.default) { shakeOffset = 6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.default) { shakeOffset = 0 }
            pin = ""
        }
    }
    
    private func triggerBiometrics() {
        authService.authenticateWithBiometrics { success in
            if success {
                onAuthenticated()
            }
        }
    }
}

#Preview {
    AdminLoginSheet(
        authService: AdminAuthService(),
        onAuthenticated: {},
        onDismiss: {}
    )
}
