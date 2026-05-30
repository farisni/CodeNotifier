//
//  MenuBarManager.swift
//  CodeNotifier
//

import AppKit
import OSLog

final class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private let logger = Logger(subsystem: "com.faris.CodeNotifier.app", category: "MenuBar")
    private let notificationManager = NotificationManager()

    func setup() {
        // 固定宽度 18pt，标准菜单栏图标尺寸
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            let icon = NSImage(named: "MenuBarIcon") ?? NSImage(
                systemSymbolName: "bell.fill",
                accessibilityDescription: "CodeNotifier"
            )
            icon?.isTemplate = true
            // 限制图标为 16pt，适配菜单栏高度
            icon?.size = NSSize(width: 20, height: 20)
            button.image = icon
            button.imagePosition = .imageOnly
            button.imageScaling = .scaleProportionallyDown
        }

        let menu = NSMenu()

        let statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.secondaryLabelColor,
            .font: NSFont.menuFont(ofSize: 13)
        ]
        statusMenuItem.attributedTitle = NSAttributedString(
            string: "服务运行中 - Port: 3456",
            attributes: attrs
        )
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())

        let testItem = NSMenuItem(
            title: "发送测试通知",
            action: #selector(sendTestNotification),
            keyEquivalent: ""
        )
        testItem.target = self
        menu.addItem(testItem)
        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "退出 CodeNotifier",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        logger.info("状态栏菜单已创建")
    }

    @objc private func sendTestNotification() {
        notificationManager.send(
            title: "测试通知",
            body: "如果你能看到这条消息，说明通知权限已开启 ✅"
        )
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
