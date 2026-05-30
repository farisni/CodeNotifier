//
//  HttpServerManager.swift
//  CodeNotifier
//

//  类比 Java：这相当于 Spring Boot 内嵌的 Tomcat + 一个 @RestController。
//  Swifter 是一个纯 Swift 的轻量 HTTP 库（类比 Jetty），单文件无依赖。

import Swifter
import OSLog
import Foundation

final class HttpServerManager {
    private let server = HttpServer()
    private let logger = Logger(subsystem: "com.faris.CodeNotifier", category: "HTTPServer")
    private let notificationManager = NotificationManager()

    func start(port: in_port_t) {
        server["/notify"] = { [weak self] request in
            guard let self = self else {
                return .internalServerError
            }

            let rawTitle = request.queryParams.first(where: { $0.0 == "title" })?.1 ?? "CodeNotifier"
            let rawBody  = request.queryParams.first(where: { $0.0 == "body"  })?.1 ?? "收到一条新消息"

            let title = self.decodeParam(rawTitle)
            let body  = self.decodeParam(rawBody)

            // 长度校验：标题超过上限时仍然发送（由 NotificationManager 截断），
            // 但在 HTTP 响应中给出提示，让调用方知道发生了截断。
            var warnings: [String] = []
            if title.count > NotificationManager.maxTitleLength {
                warnings.append("标题过长(\(title.count)字符)，已截断至\(NotificationManager.maxTitleLength)字符")
            }
            if body.count > NotificationManager.maxBodyLength {
                warnings.append("正文过长(\(body.count)字符)，已截断至\(NotificationManager.maxBodyLength)字符")
            }

            self.logger.info("收到通知请求 → title: \(title), body: \(body)")
            self.notificationManager.send(title: title, body: body)

            if warnings.isEmpty {
                return .ok(.text("通知已发送"))
            } else {
                return .ok(.text("通知已发送（含截断）\n" + warnings.joined(separator: "\n")))
            }
        }

        do {
            try server.start(port)
            logger.info("HTTP 服务已启动，监听端口 \(port)")
        } catch {
            logger.error("HTTP 服务启动失败: \(error.localizedDescription)")
        }
    }

    /// 解码 query 参数值，自动修复 Swifter 导致的 Latin-1 乱码。
    private func decodeParam(_ raw: String) -> String {
        // 第一步：百分号解码（curl 做了 URL Encode 时）
        if let decoded = raw.removingPercentEncoding, decoded != raw {
            return decoded
        }

        // 第二步：修复 Latin-1 Mojibake
        if let latin1Data = raw.data(using: .isoLatin1),
           let utf8 = String(data: latin1Data, encoding: .utf8) {
            return utf8
        }

        return raw
    }

    func stop() {
        server.stop()
        logger.info("HTTP 服务已停止")
    }
}
