# Changelog

All notable changes to StudKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-11

### Added
- 🎉 Initial release of StudKit
- ✨ System-wide text selection detection using Accessibility API
- 🎯 Intelligent floating menu positioning with screen boundary adaptation
- 📋 One-click copy functionality
- 🔒 Privacy protection: automatic filtering of password fields and sensitive text
- 🎨 Light/Dark mode support with automatic theme detection
- ⚡ Low power consumption: ≤1% CPU usage, ≤50MB memory
- 🚀 Fast response time: ≤150ms from selection to menu display
- 🔧 Accessibility permission management with guided setup
- 📱 Status bar integration for easy control (Resume/Pause/Quit)
- 🎭 Smooth fade-in/fade-out animations (0.1s duration)
- ⏱️ Auto-hide after 5 seconds of inactivity
- 🌐 Wide compatibility: Native apps, Electron apps, Browsers, Code editors
- 💾 Text caching: Reuse text selected within 10 seconds
- 🎨 Menu UI: 80x36px rounded rectangle with semi-transparent background
- 🖱️ Smart interaction: Click outside or switch apps to hide menu
- 📏 Precise positioning: Menu follows text selection bounds
- 🔄 Focus change detection: Auto-hide when switching applications
- 🛡️ Secure text field detection: Skip AXSecureTextField elements
- 🎯 Selection bounds calculation with coordinate system conversion

### Technical Features
- Built with Swift and AppKit for native macOS performance
- Accessibility API (AXUIElement) for system-wide text detection
- NSEvent monitoring for global mouse event capture
- NSPasteboard integration for clipboard operations
- Custom NSWindow subclass for floating menu implementation
- Event throttling for optimal performance
- Memory-efficient architecture with weak references
- Comprehensive error handling and fallback mechanisms

### Compatibility
- ✅ macOS 10.15 (Catalina) and later
- ✅ Intel, M1, M2, M3 chip support
- ✅ Native applications (Pages, Keynote, Xcode, TextEdit)
- ✅ Electron applications (VS Code, Slack, Notion)
- ✅ Web browsers (Chrome, Safari, Firefox)
- ✅ Office applications (Microsoft Word, Excel, PowerPoint)
- ✅ Code editors (Xcode, VS Code, Sublime Text)

### Documentation
- 📖 Comprehensive README with installation and usage instructions
- 🏗️ Detailed architecture documentation (ARCHITECTURE.md)
- 🤝 Contributing guidelines (CONTRIBUTING.md)
- 🔨 Build scripts and Makefile for easy compilation
- 📝 Inline code documentation for all public APIs

### Performance Metrics
- Response latency: Mouse release → Menu display ≤ 150ms
- Text reading timeout: ≤ 100ms
- Copy operation: Button click → Clipboard write ≤ 50ms
- CPU usage: ≤ 1% during background operation
- Memory usage: ≤ 50MB
- Animation duration: 0.1s for fade in/out

### Known Limitations
- Requires Accessibility permission to function
- Some web applications may not support text bounds detection
- Multi-monitor support may need position adjustment
- Cannot detect text in screenshot or image content

## [Unreleased]

### Planned Features
- [ ] Multi-monitor position optimization
- [ ] Custom keyboard shortcut configuration
- [ ] Copy history with search functionality
- [ ] Additional menu actions (Search, Translate, Format)
- [ ] Plugin system for extensibility
- [ ] Performance monitoring and optimization
- [ ] Graphical configuration interface
- [ ] Automatic updates mechanism
- [ ] Menu appearance customization
- [ ] Text transformation utilities

### Under Consideration
- [ ] Support for macOS 10.14 (Mojave) and earlier
- [ ] Accessibility for users with disabilities
- [ ] Multi-language support for UI
- [ ] Cloud sync for settings and history
- [ ] Advanced text processing features

## Notes

For more information about each release, please visit the [GitHub Releases](https://github.com/kangkang88888/StudKit/releases) page.

To report bugs or request features, please open an issue on [GitHub Issues](https://github.com/kangkang88888/StudKit/issues).
