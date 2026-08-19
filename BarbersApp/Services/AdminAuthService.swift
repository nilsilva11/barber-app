import Foundation
import LocalAuthentication
import Observation

@Observable
final class AdminAuthService {
    var isAuthenticated: Bool = false
    var defaultPIN: String = "1234"
    var isBiometricsAvailable: Bool = false
    
    init() {
        checkBiometricsAvailability()
    }
    
    func verifyPIN(_ enteredPIN: String) -> Bool {
        if enteredPIN == defaultPIN {
            isAuthenticated = true
            return true
        }
        return false
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access Barber Admin Console"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.isAuthenticated = true
                    }
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
    
    private func checkBiometricsAvailability() {
        let context = LAContext()
        var error: NSError?
        isBiometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}
