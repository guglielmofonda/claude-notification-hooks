import AppKit

class BlinkDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var view: NSView!
    let dotSize: CGFloat = 30
    var colorIndex = 0
    let sequence: [(CGColor, TimeInterval)] = [
        (NSColor.systemYellow.cgColor, 0.4),
        (NSColor.systemRed.cgColor, 0.4),
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = NSScreen.main else { NSApp.terminate(nil); return }

        // Position: centered horizontally, just below the menu bar
        let menuBarHeight: CGFloat = NSStatusBar.system.thickness
        let x = screen.frame.midX - dotSize / 2
        let y = screen.frame.maxY - menuBarHeight - dotSize - 10

        window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: dotSize, height: dotSize),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = NSWindow.Level(Int(CGShieldingWindowLevel()))
        window.ignoresMouseEvents = true
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        view = NSView(frame: NSRect(x: 0, y: 0, width: dotSize, height: dotSize))
        view.wantsLayer = true
        view.layer?.cornerRadius = dotSize / 2
        window.contentView = view

        showNext()
    }

    func showNext() {
        if colorIndex >= sequence.count {
            window.orderOut(nil)
            NSApp.terminate(nil)
            return
        }

        let (color, duration) = sequence[colorIndex]
        view.layer?.backgroundColor = color
        window.orderFrontRegardless()
        colorIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.showNext()
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = BlinkDelegate()
app.delegate = delegate
app.run()
