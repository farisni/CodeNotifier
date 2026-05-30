//
//  MenuBarManager.swift
//  CodeNotifier
//

//  类比 Java：这相当于 Java Swing 的 SystemTray + PopupMenu 组合。
//  NSStatusBar 是 macOS 右上角状态栏的编程接口，
//  NSStatusItem 是其中的一个"图标槽位"（类似于 TrayIcon），
//  NSMenu 是点击后弹出的菜单（类似于 JPopupMenu）。

import AppKit
import OSLog

final class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private let logger = Logger(subsystem: "com.faris.CodeNotifier", category: "MenuBar")
    private let notificationManager = NotificationManager()

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "bell.fill",
                accessibilityDescription: "CodeNotifier"
            )
        }

        let menu = NSMenu()

        // 状态文本（灰色，不可点击）
        let statusMenuItem = NSMenuItem(
            title: "",
            action: nil,
            keyEquivalent: ""
        )
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

        // 发送测试通知
        let testItem = NSMenuItem(
            title: "发送测试通知",
            action: #selector(sendTestNotification),
            keyEquivalent: ""
        )
        testItem.target = self
        menu.addItem(testItem)

        menu.addItem(NSMenuItem.separator())

        // 退出
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

    // MARK: - Actions

    @objc private func sendTestNotification() {
        notificationManager.send(
            title: "测试通知",
            body: "如果你能看到这条消息，说明通知权限已开启 ✅"
        )
        logger.info("已发送测试通知")
    }

    @objc private func quitApp() {
        logger.info("用户退出 CodeNotifier")
        NSApp.terminate(nil)
    }
}
