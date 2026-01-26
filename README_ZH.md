# SystemPulse

🌍 **支持7种语言:** 🇺🇸 [English](README.md) | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 中文

一款轻量级的原生macOS菜单栏应用程序，通过精美的迷你图表实时显示系统指标。

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![许可证](https://img.shields.io/badge/许可证-MIT-green)

## 功能特性

- **CPU监控** - 使用百分比、温度、频率（Intel）、每核心跟踪和历史图表
- **内存监控** - 已用/空闲内存、活动/wired/压缩内存分布
- **GPU监控** - 使用百分比、温度、显示刷新率（Hz）
- **网络监控** - 下载/上传速度、本地和公网IP、会话统计
- **磁盘监控** - 使用百分比、可用空间、SSD健康状态（如可用）
- **电池监控** - 电量、充电状态、剩余时间、功耗
- **风扇监控** - 每个风扇的转速RPM（如可用）
- **系统信息** - 负载平均值、进程数、交换空间使用、内核版本、运行时间、屏幕亮度
- **多语言支持** - 从菜单选择您的语言（支持7种语言）

### 交互功能

- **点击**任意卡片打开相应的系统应用（活动监视器、磁盘工具、系统设置等）
- **右键点击**菜单栏图标获取快捷菜单，包含设置和语言选择

## 系统要求

- macOS 12.0（Monterey）或更高版本
- Apple Silicon或Intel Mac

## 安装

> **关于公证：** SystemPulse目前未经Apple公证。公证是Apple的安全流程，在分发前扫描应用程序是否存在恶意软件。没有公证，macOS会在首次启动时显示警告。对于像SystemPulse这样的开源应用程序，您可以自行检查代码，因此绕过此警告是安全的。公证计划在未来版本中实现。

### 选项1：Homebrew（推荐）

```bash
brew tap bluewave-labs/systempulse
brew install --cask systempulse
```

首次启动时，右键点击应用 → 打开 → 确认。或运行：`xattr -cr /Applications/SystemPulse.app`

### 选项2：下载DMG

1. 从[Releases](https://github.com/bluewave-labs/systempulse/releases)下载最新的DMG
2. 打开DMG并将SystemPulse拖到应用程序文件夹
3. 首次启动时，右键 → 打开 → 确认（参见上面关于公证的说明）

### 选项3：从源代码构建

1. 克隆仓库：
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. 构建应用：
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. 运行：
   ```bash
   ./SystemPulse
   ```

### 选项4：创建应用程序包（可选）

如果您希望SystemPulse显示为正式的macOS应用程序：

1. 创建应用程序结构：
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. 创建`SystemPulse.app/Contents/Info.plist`：
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>CFBundleExecutable</key>
       <string>SystemPulse</string>
       <key>CFBundleIdentifier</key>
       <string>com.bluewave.systempulse</string>
       <key>CFBundleName</key>
       <string>SystemPulse</string>
       <key>CFBundleVersion</key>
       <string>1.0</string>
       <key>LSMinimumSystemVersion</key>
       <string>14.0</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

3. 移动到应用程序文件夹（可选）：
   ```bash
   mv SystemPulse.app /Applications/
   ```

### 选项5：使用Automator运行

此方法允许SystemPulse独立于终端运行，因此即使关闭终端后它也会继续运行。

1. 首先构建SystemPulse（参见上面的选项1）

2. 打开**Automator**（在Spotlight中搜索）

3. 点击**新建文稿**并选择**应用程序**

4. 在搜索栏中输入"运行Shell脚本"并将其拖到工作流区域

5. 将默认文本替换为SystemPulse二进制文件的完整路径：
   ```bash
   /path/to/systempulse/SystemPulse
   ```
   例如，如果您克隆到了主文件夹：
   ```bash
   ~/systempulse/SystemPulse
   ```

6. 前往**文件** > **存储**，将其保存为"SystemPulse"到您的应用程序文件夹

7. 双击保存的Automator应用程序运行SystemPulse

**提示：** 您可以将SystemPulse添加到登录项，以便在启动时自动启动：
1. 打开**系统设置** > **通用** > **登录项**
2. 点击**+**并选择您的SystemPulse Automator应用程序

## 使用方法

运行后，SystemPulse将出现在菜单栏中，显示CPU和内存使用情况。

- **左键点击**菜单栏项目打开详细面板
- **右键点击**获取快捷菜单，包含设置、语言选择和退出选项
- **点击**卡片打开相关的系统应用

### 更改语言

1. 右键点击菜单栏中的SystemPulse图标
2. 从菜单中选择**语言**
3. 从子菜单中选择您喜欢的语言

## 技术细节

SystemPulse使用原生macOS API获取精确的指标：

- **CPU**：`host_processor_info()` Mach API
- **内存**：`host_statistics64()` Mach API
- **GPU**：IOKit `IOAccelerator`服务
- **网络**：用于接口统计的`getifaddrs()`
- **电池**：来自IOKit的`IOPSCopyPowerSourcesInfo()`
- **温度/风扇**：通过IOKit访问SMC（系统管理控制器）

## 贡献

欢迎贡献！请随时提交拉取请求。

### 添加翻译

SystemPulse支持轻松添加新语言。要添加新语言：

1. 在`Language`枚举中添加新的case
2. 在`L10n`结构体中为所有字符串添加翻译
3. 提交拉取请求

## 许可证

MIT许可证 - 详情请参阅[LICENSE](LICENSE)。

## 致谢

使用Swift和AppKit构建，实现原生macOS性能。
