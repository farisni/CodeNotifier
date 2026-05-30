# CodeNotifier

轻量级 macOS 状态栏 Webhook 通知接收器。任何外部服务（CI/CD、脚本、自动化工具）向你的 Mac 发送 HTTP 请求，即可弹出系统原生通知。

## 功能

- 🔔 **状态栏菜单** — 无 Dock 图标，纯菜单栏运行，显示服务端口和运行状态
- 🌐 **轻量 HTTP Server** — 基于 Swifter，监听 `127.0.0.1:3456`
- 📢 **原生通知** — 调用 macOS `UserNotifications`，支持中文、自动截断超长文字
- 🧪 **测试按钮** — 菜单栏一键发送测试通知，验证通知权限
- 🎨 **自定义图标** — 状态栏图标和 App 图标均可在 Asset Catalog 中替换

## 快速开始

```bash
# 启动 App（菜单栏右上角出现图标）

# 发送通知（完整参数）
curl "http://127.0.0.1:3456/notify?title=构建成功&body=CI/CD 流水线已通过"

# 无参数（使用默认值）
curl "http://127.0.0.1:3456/notify"

# 仅标题
curl "http://127.0.0.1:3456/notify?title=爬虫任务完成"
```

### 接口说明

```
GET /notify
```

| 参数 | 必填 | 默认值 | 上限 |
|---|---|---|---|
| `title` | 否 | CodeNotifier | 128 字符 |
| `body` | 否 | 收到一条新消息 | 1024 字符 |

超出上限自动截断并尾部加省略号，HTTP 响应会提示截断信息。

## 技术栈

| 层 | 技术 | 说明 |
|---|---|---|
| 语言 | Swift 5 | — |
| UI | AppKit (NSStatusBar + NSMenu) | 状态栏原生控件 |
| HTTP | [Swifter](https://github.com/httpswift/swifter) | 纯 Swift 轻量 HTTP 库 |
| 通知 | UserNotifications | macOS 系统通知框架 |
| 依赖管理 | Swift Package Manager | 类比 Maven / Gradle |
| 最低系统 | macOS 15.6 | — |

## 项目结构

```
CodeNotifier/
├── CodeNotifierApp.swift              # App 入口（static func main 显式启动）
├── CodeNotifier.entitlements          # 沙盒网络权限声明
├── Assets.xcassets/
│   ├── AppIcon.appiconset/            # App 图标（通知弹窗、Finder 显示）
│   └── MenuBarIcon.imageset/          # 状态栏自定义图标
└── Managers/
    ├── HttpServerManager.swift        # HTTP 服务封装 + /notify 路由
    ├── NotificationManager.swift      # 通知权限申请 + 发送
    └── MenuBarManager.swift           # 状态栏图标 + 右键菜单
```

## 开发

```bash
# 命令行编译
xcodebuild -project CodeNotifier.xcodeproj -scheme CodeNotifier build

# 或 Xcode 打开项目 → Cmd+R 运行
```

## 许可

MIT
