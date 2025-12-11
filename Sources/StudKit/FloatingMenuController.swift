import Cocoa

class FloatingMenuController {
    private var menuWindow: FloatingMenuWindow?
    private var currentText: String?
    private var hideTimer: Timer?
    private let autoHideDelay: TimeInterval = 5.0
    
    func showMenu(at bounds: NSRect, with text: String) {
        // Cancel existing hide timer
        hideTimer?.invalidate()
        hideTimer = nil
        
        currentText = text
        
        // Calculate menu position
        let menuPosition = calculateMenuPosition(for: bounds)
        
        if let existingWindow = menuWindow {
            // Update existing window
            existingWindow.setFrameOrigin(menuPosition)
            existingWindow.updateText(text)
            existingWindow.show()
        } else {
            // Create new window
            menuWindow = FloatingMenuWindow(at: menuPosition, text: text)
            menuWindow?.onCopyClicked = { [weak self] in
                self?.handleCopy()
            }
            menuWindow?.onClickOutside = { [weak self] in
                self?.hideMenu()
            }
            menuWindow?.show()
        }
        
        // Setup auto-hide timer
        setupAutoHideTimer()
    }
    
    func hideMenu() {
        hideTimer?.invalidate()
        hideTimer = nil
        menuWindow?.hide()
    }
    
    private func calculateMenuPosition(for selectionBounds: NSRect) -> NSPoint {
        let menuSize = CGSize(width: 80, height: 36)
        
        guard let screen = NSScreen.main else {
            return NSPoint(x: selectionBounds.maxX + 5, y: selectionBounds.maxY - 2)
        }
        
        let screenFrame = screen.visibleFrame
        
        // Default position: top-right of selection
        var x = selectionBounds.maxX + 5
        var y = selectionBounds.maxY - 2
        
        // Adjust for right boundary
        if x + menuSize.width > screenFrame.maxX {
            // Move to left of selection
            x = selectionBounds.minX - menuSize.width - 5
        }
        
        // Adjust for top boundary
        if y + menuSize.height > screenFrame.maxY {
            // Move to bottom of selection
            y = selectionBounds.minY - menuSize.height - 5
        }
        
        // Adjust for left boundary
        if x < screenFrame.minX {
            // Center horizontally with selection
            x = selectionBounds.midX - menuSize.width / 2
        }
        
        // Adjust for bottom boundary
        if y < screenFrame.minY {
            // Center vertically with selection
            y = selectionBounds.midY - menuSize.height / 2
        }
        
        // Clamp to screen bounds
        x = max(screenFrame.minX, min(x, screenFrame.maxX - menuSize.width))
        y = max(screenFrame.minY, min(y, screenFrame.maxY - menuSize.height))
        
        return NSPoint(x: x, y: y)
    }
    
    private func setupAutoHideTimer() {
        hideTimer = Timer.scheduledTimer(withTimeInterval: autoHideDelay, repeats: false) { [weak self] _ in
            self?.hideMenu()
        }
    }
    
    private func handleCopy() {
        guard let text = currentText else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Hide menu after short delay for visual feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.hideMenu()
        }
    }
}

class FloatingMenuWindow: NSWindow {
    private let copyButton: NSButton
    private var currentText: String
    var onCopyClicked: (() -> Void)?
    var onClickOutside: (() -> Void)?
    private var clickOutsideMonitor: Any?
    
    init(at position: NSPoint, text: String) {
        self.currentText = text
        
        let menuSize = CGSize(width: 80, height: 36)
        let contentRect = NSRect(origin: position, size: menuSize)
        
        // Create copy button
        copyButton = NSButton(frame: NSRect(x: 0, y: 0, width: menuSize.width, height: menuSize.height))
        copyButton.title = "Copy"
        copyButton.bezelStyle = .rounded
        copyButton.isBordered = false
        copyButton.wantsLayer = true
        
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        self.isMovableByWindowBackground = false
        self.hasShadow = true
        
        setupContentView()
        setupButton()
    }
    
    private func setupContentView() {
        let containerView = NSView(frame: self.contentView!.bounds)
        containerView.wantsLayer = true
        
        // Setup background with rounded corners
        let appearance = NSApp.effectiveAppearance
        let isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        
        if isDarkMode {
            containerView.layer?.backgroundColor = NSColor(red: 0.157, green: 0.157, blue: 0.157, alpha: 0.9).cgColor
        } else {
            containerView.layer?.backgroundColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9).cgColor
        }
        
        containerView.layer?.cornerRadius = 8.0
        
        containerView.addSubview(copyButton)
        self.contentView = containerView
    }
    
    private func setupButton() {
        copyButton.target = self
        copyButton.action = #selector(copyButtonClicked)
        
        // Setup button appearance
        copyButton.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        copyButton.layer?.cornerRadius = 6.0
        
        // Setup tracking area for hover effect
        let trackingArea = NSTrackingArea(
            rect: copyButton.bounds,
            options: [.activeAlways, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        copyButton.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        let appearance = NSApp.effectiveAppearance
        let isDarkMode = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        
        if isDarkMode {
            copyButton.layer?.backgroundColor = NSColor(red: 0.235, green: 0.235, blue: 0.235, alpha: 0.8).cgColor
        } else {
            copyButton.layer?.backgroundColor = NSColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 0.8).cgColor
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        copyButton.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    @objc private func copyButtonClicked() {
        onCopyClicked?()
    }
    
    func updateText(_ text: String) {
        currentText = text
    }
    
    func show() {
        // Fade in animation
        self.alphaValue = 0.0
        self.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            self.animator().alphaValue = 1.0
        })
        
        // Setup click outside monitor
        setupClickOutsideMonitor()
    }
    
    func hide() {
        // Remove click outside monitor
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
            clickOutsideMonitor = nil
        }
        
        // Fade out animation
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            self.animator().alphaValue = 0.0
        }, completionHandler: {
            self.orderOut(nil)
        })
    }
    
    private func setupClickOutsideMonitor() {
        // Remove existing monitor
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        // Monitor clicks outside the menu
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self else { return }
            
            let clickLocation = event.locationInWindow
            let menuFrame = self.frame
            
            // Check if click is outside menu
            if !menuFrame.contains(clickLocation) {
                self.onClickOutside?()
            }
        }
    }
}
