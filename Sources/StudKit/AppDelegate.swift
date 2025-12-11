import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var accessibilityManager: AccessibilityManager?
    private var textSelectionMonitor: TextSelectionMonitor?
    private var floatingMenuController: FloatingMenuController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Setup status bar menu
        setupStatusBarMenu()
        
        // Initialize managers
        accessibilityManager = AccessibilityManager()
        floatingMenuController = FloatingMenuController()
        
        // Check accessibility permissions
        if accessibilityManager?.checkPermissions() == true {
            startMonitoring()
        } else {
            accessibilityManager?.requestPermissions()
        }
    }
    
    private func setupStatusBarMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Use a simple text indicator for the status bar
            button.title = "📋"
        }
        
        let menu = NSMenu()
        
        let resumeItem = NSMenuItem(title: "Resume", action: #selector(resumeMonitoring), keyEquivalent: "")
        resumeItem.target = self
        menu.addItem(resumeItem)
        
        let pauseItem = NSMenuItem(title: "Pause", action: #selector(pauseMonitoring), keyEquivalent: "")
        pauseItem.target = self
        menu.addItem(pauseItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    private func startMonitoring() {
        textSelectionMonitor = TextSelectionMonitor(floatingMenuController: floatingMenuController!)
        textSelectionMonitor?.startMonitoring()
    }
    
    @objc private func resumeMonitoring() {
        if accessibilityManager?.checkPermissions() == true {
            startMonitoring()
        }
    }
    
    @objc private func pauseMonitoring() {
        textSelectionMonitor?.stopMonitoring()
        floatingMenuController?.hideMenu()
    }
    
    @objc private func quitApp() {
        textSelectionMonitor?.stopMonitoring()
        NSApplication.shared.terminate(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        textSelectionMonitor?.stopMonitoring()
    }
}
