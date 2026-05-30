//
//  MenuBarManager.swift
//  CodeNotifier
//

//  类比 Java：这相当于 Java Swing 的 SystemTray + PopupMenu 组合。
//  NSStatusBar 是 macOS 右上角状态栏的编程接口，
//  NSStatusItem 是其中的一个"图标槽位"（类似于 TrayIcon），
//  NSMenu 是点击后弹出的菜单（类似于 JPopupMenu）。
//
//  注意：Swift 里 NSMenu 的 item 用 target-action 模式绑定点击事件，
//  类似于 Java AWT 的 ActionListener，但更底层。

import AppKit
import OSLog

final class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private let logger = Logger(subsystem: "com.faris.CodeNotifier", category: "MenuBar")
    private let notificationManager = NotificationManager()

    /// 创建状态栏图标和菜单。
    /// 类似于在 Java 中：
    ///   SystemTray.getSystemTray().add(new TrayIcon(image, "CodeNotifier"))
    func setup() {
        // variableLength 表示图标宽度随内容自动调整
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // 设置图标：使用 SF Symbol 的 bell.fill（铃铛图标）
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "bell.fill",
                accessibilityDescription: "CodeNotifier"
            )
            // 在 macOS 15 / Xcode 26 中，默认模板渲染即可
        }

        // 构建菜单
        let menu = NSMenu()

        // ----- 状态文本（灰色禁用项，纯展示） -----
        let statusItem = NSMenuItem(
            title: "服务运行中 - Port: 3456",
            action: nil,
            keyEquivalent: ""
        )
        statusItem.isEnabled = false  // 灰字显示，不可点击
        // attributedTitle 允许自定义颜色，这里用 secondaryLabelColor（系统灰色）
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.secondaryLabelColor,
            .font: NSFont.menuFont(ofSize: 13)
        ]
        statusItem.attributedTitle = NSAttributedString(string: "服务运行中 - Port: 3456", attributes: attributes)
        menu.addItem(statusItem)

        // ----- 分隔线 -----
        menu.addItem(NSMenuItem.separator())

        // ----- 发送测试通知 -----
        // 类比：JMenuItem testItem = new JMenuItem("发送测试通知");
        //        testItem.addActionListener(e -> notificationManager.send(...));
        let testItem = NSMenuItem(
            title: "发送测试通知",
            action: #selector(sendTestNotification),
            keyEquivalent: ""
        )
        testItem.target = self
        menu.addItem(testItem)

        // ----- 分隔线 -----
        menu.addItem(NSMenuItem.separator())

        // ----- 退出 -----
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
        NSApplication.shared.terminate(nil)
    }
}
