import Cocoa
import ApplicationServices

class AccessibilityManager {
    
    /// Check if accessibility permissions are granted
    func checkPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    /// Request accessibility permissions from the user
    func requestPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        // Show alert to guide user
        DispatchQueue.main.async {
            self.showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "StudKit needs accessibility permissions to detect text selection across all applications.\n\nPlease enable it in:\nSystem Preferences > Security & Privacy > Accessibility"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            openAccessibilityPreferences()
        }
    }
    
    private func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    /// Monitor permission status changes
    func startPermissionMonitoring(onPermissionGranted: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.checkPermissions() {
                onPermissionGranted()
                timer.invalidate()
            }
        }
    }
}
