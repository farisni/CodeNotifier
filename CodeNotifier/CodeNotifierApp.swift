//
//  CodeNotifierApp.swift
//  CodeNotifier
//

//  类比 Java：这是 Spring Boot 的 main() 入口 —— 组合所有"Bean"并启动应用。
//
//  SwiftUI 的 @main 标记相当于 Java 的 public static void main，
//  @NSApplicationDelegateAdaptor 相当于在 Spring 中注入一个自定义的
//  ApplicationRunner / CommandLineRunner，在应用启动后执行初始化逻辑。
//
//  注意：LSUIElement = YES（在 Info.plist 中配置）后，App 不会出现 Dock 图标，
//  类似于 Java 后台守护进程（daemon thread）。

import SwiftUI
import AppKit
import OSLog

// MARK: - App 入口

@main
struct CodeNotifierApp: App {
    // @NSApplicationDelegateAdaptor 会将 AppDelegate 注册为 NSApplication 的代理，
    // 类似于在 Spring Boot 中 @Autowired 一个实现了 ApplicationListener 的 Bean。
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 空场景：不需要任何窗口。
        // 如果 App 的 body 里没有任何 WindowGroup，SwiftUI 就不会自动创建主窗口。
        // 这里用 Settings 场景占位（Cmd+, 也不会有实质窗口），完全靠状态栏菜单运作。
        Settings {
            EmptyView()
        }
    }
}

// MARK: - App 生命周期代理

// 类似于 Java 中 implements ApplicationListener<ApplicationReadyEvent>
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "com.faris.CodeNotifier", category: "AppLifecycle")
    private let httpServer = HttpServerManager()
    private var menuBarManager: MenuBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("CodeNotifier 启动中...")

        // 1. 创建状态栏图标（必须在主线程，NSStatusBar 要求）
        menuBarManager = MenuBarManager()
        menuBarManager.setup()

        // 2. 申请通知权限（首次启动弹出系统授权弹窗）
        NotificationManager().requestPermission()

        // 3. 启动 HTTP 服务（端口 3456）
        httpServer.start(port: 3456)

        logger.info("CodeNotifier 启动完成 ✅ — curl http://127.0.0.1:3456/notify?title=你好&body=世界")
    }

    func applicationWillTerminate(_ notification: Notification) {
        httpServer.stop()
        logger.info("CodeNotifier 已退出")
    }
}
