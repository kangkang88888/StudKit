import Cocoa
import ApplicationServices

class TextSelectionMonitor {
    private var mouseEventMonitor: Any?
    private var focusChangeObserver: Any?
    private var floatingMenuController: FloatingMenuController
    private var lastSelectedText: String?
    private var lastSelectionTime: Date?
    private let textCacheTimeout: TimeInterval = 10.0
    
    init(floatingMenuController: FloatingMenuController) {
        self.floatingMenuController = floatingMenuController
    }
    
    func startMonitoring() {
        setupMouseEventMonitor()
        setupFocusChangeObserver()
    }
    
    func stopMonitoring() {
        if let monitor = mouseEventMonitor {
            NSEvent.removeMonitor(monitor)
            mouseEventMonitor = nil
        }
        
        if let observer = focusChangeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            focusChangeObserver = nil
        }
    }
    
    private func setupMouseEventMonitor() {
        // Monitor mouse up events to detect text selection
        mouseEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] event in
            // Add small delay to ensure selection is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self?.handlePotentialTextSelection()
            }
        }
    }
    
    private func setupFocusChangeObserver() {
        // Monitor app focus changes
        focusChangeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Hide menu when switching apps
            self?.floatingMenuController.hideMenu()
        }
    }
    
    private func handlePotentialTextSelection() {
        guard let selectedText = getSelectedText(),
              !selectedText.isEmpty,
              selectedText.count >= 1 else {
            return
        }
        
        // Check if it's the same text within cache timeout
        if let lastText = lastSelectedText,
           let lastTime = lastSelectionTime,
           lastText == selectedText,
           Date().timeIntervalSince(lastTime) < textCacheTimeout {
            // Use cached text, just update menu position
            if let bounds = getSelectionBounds() {
                floatingMenuController.showMenu(at: bounds, with: selectedText)
            }
            return
        }
        
        // New text selection
        lastSelectedText = selectedText
        lastSelectionTime = Date()
        
        if let bounds = getSelectionBounds() {
            floatingMenuController.showMenu(at: bounds, with: selectedText)
        }
    }
    
    private func getSelectedText() -> String? {
        let timeout: TimeInterval = 0.1
        let startTime = Date()
        
        // Get the system-wide focused element
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        let appRef = AXUIElementCreateApplication(focusedApp.processIdentifier)
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appRef, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard result == .success, let element = focusedElement else {
            return fallbackToClipboard()
        }
        
        // Check timeout
        if Date().timeIntervalSince(startTime) > timeout {
            return nil
        }
        
        // Check if it's a secure text field
        if isSecureTextField(element as! AXUIElement) {
            return nil
        }
        
        // Try to get selected text
        var selectedTextValue: CFTypeRef?
        let selectedTextResult = AXUIElementCopyAttributeValue(
            element as! AXUIElement,
            kAXSelectedTextAttribute as CFString,
            &selectedTextValue
        )
        
        if selectedTextResult == .success, let text = selectedTextValue as? String {
            return text
        }
        
        // Fallback to clipboard
        return fallbackToClipboard()
    }
    
    private func isSecureTextField(_ element: AXUIElement) -> Bool {
        var roleValue: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleValue)
        
        if let role = roleValue as? String {
            return role == "AXSecureTextField"
        }
        
        return false
    }
    
    private func fallbackToClipboard() -> String? {
        // Note: This is a simplified fallback
        // In practice, reading clipboard without user action may not work reliably
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }
    
    private func getSelectionBounds() -> NSRect? {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        let appRef = AXUIElementCreateApplication(focusedApp.processIdentifier)
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appRef, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard result == .success, let element = focusedElement else {
            return nil
        }
        
        // Try to get selected text range bounds
        var selectedRangeValue: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(
            element as! AXUIElement,
            kAXSelectedTextRangeAttribute as CFString,
            &selectedRangeValue
        )
        
        if rangeResult == .success, let range = selectedRangeValue {
            // Try to get bounds for the range
            var boundsValue: CFTypeRef?
            let boundsResult = AXUIElementCopyParameterizedAttributeValue(
                element as! AXUIElement,
                kAXBoundsForRangeParameterizedAttribute as CFString,
                range,
                &boundsValue
            )
            
            if boundsResult == .success, let bounds = boundsValue {
                var rect = CGRect.zero
                if AXValueGetValue(bounds as! AXValue, .cgRect, &rect) {
                    // Convert to screen coordinates
                    return NSRect(
                        x: rect.origin.x,
                        y: NSScreen.screens[0].frame.height - rect.origin.y - rect.height,
                        width: rect.width,
                        height: rect.height
                    )
                }
            }
        }
        
        // Fallback: try to get position of the focused element
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        
        AXUIElementCopyAttributeValue(element as! AXUIElement, kAXPositionAttribute as CFString, &positionValue)
        AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSizeAttribute as CFString, &sizeValue)
        
        if let posVal = positionValue, let sizeVal = sizeValue {
            var position = CGPoint.zero
            var size = CGSize.zero
            
            if AXValueGetValue(posVal as! AXValue, .cgPoint, &position),
               AXValueGetValue(sizeVal as! AXValue, .cgSize, &size) {
                return NSRect(
                    x: position.x,
                    y: NSScreen.screens[0].frame.height - position.y - size.height,
                    width: size.width,
                    height: size.height
                )
            }
        }
        
        return nil
    }
}
