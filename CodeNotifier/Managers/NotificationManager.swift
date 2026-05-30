//
//  NotificationManager.swift
//  CodeNotifier
//

//  类比 Java：这相当于一个 NotificationService Bean，
//  封装了 UserNotifications 框架的权限请求和通知发送逻辑。

import UserNotifications
import OSLog

final class NotificationManager {
    /// 通知标题最大字符数（超出截断并加 …）
    static let maxTitleLength = 128
    /// 通知正文最大字符数（超出截断并加 …）
    static let maxBodyLength = 1024

    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.faris.CodeNotifier", category: "Notification")

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                self.logger.error("通知权限请求失败: \(error.localizedDescription)")
                return
            }
            if granted {
                self.logger.info("通知权限已授予")
            } else {
                self.logger.warning("通知权限被拒绝，通知功能将不可用。请在 系统设置 > 通知 中手动开启。")
            }
        }
    }

    /// 发送一条系统通知（自动截断过长文字）。
    func send(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = truncate(title, max: Self.maxTitleLength)
        content.body  = truncate(body,  max: Self.maxBodyLength)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                self.logger.error("发送通知失败: \(error.localizedDescription)")
            } else {
                self.logger.info("通知已发送: \(title)")
            }
        }
    }

    /// 截断字符串，超出 max 时末尾加 …（Unicode 安全，按字符数而非字节数）
    private func truncate(_ string: String, max: Int) -> String {
        if string.count <= max { return string }
        let endIndex = string.index(string.startIndex, offsetBy: max)
        return String(string[..<endIndex]) + "…"
    }
}
