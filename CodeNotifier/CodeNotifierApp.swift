//
//  CodeNotifierApp.swift
//  CodeNotifier
//

//  类比 Java：这是 Spring Boot 的 main() 入口。
//
//  用 @main 标记一个 struct，显式实现 static func main()，
//  手动创建 NSApplication 并设置 delegate。
//  这比 SwiftUI App 协议或 @main class Delegate 更直接可控。

import AppKit
import OSLog

@main
struct CodeNotifierLauncher {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

// MARK: - App 生命周期代理

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "com.faris.CodeNotifier", category: "AppLifecycle")
    private let httpServer = HttpServerManager()
    private var menuBarManager: MenuBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("CodeNotifier 启动中...")

        menuBarManager = MenuBarManager()
        menuBarManager.setup()

        NotificationManager().requestPermission()
        httpServer.start(port: 3456)

        logger.info("CodeNotifier 启动完成 ✅")
    }

    func applicationWillTerminate(_ notification: Notification) {
        httpServer.stop()
        logger.info("CodeNotifier 已退出")
    }
}
