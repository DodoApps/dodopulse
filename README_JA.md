# SystemPulse

🌍 **7言語対応:** 🇺🇸 [English](README.md) | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 日本語 | 🇨🇳 [中文](README_ZH.md)

美しいミニグラフでリアルタイムのシステムメトリクスを表示する、軽量でネイティブなmacOSメニューバーアプリです。

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![ライセンス](https://img.shields.io/badge/ライセンス-MIT-green)

## 機能

- **CPU監視** - 使用率、温度、周波数（Intel）、コアごとの追跡と履歴グラフ
- **メモリ監視** - 使用中/空きメモリ、アクティブ/wired/圧縮の内訳
- **GPU監視** - 使用率、温度、ディスプレイリフレッシュレート（Hz）
- **ネットワーク監視** - ダウンロード/アップロード速度、ローカル＆パブリックIP、セッション合計
- **ディスク監視** - 使用率、空き容量、SSD健康状態（利用可能な場合）
- **バッテリー監視** - 充電レベル、充電状態、残り時間、消費電力
- **ファン監視** - 各ファンのRPM（利用可能な場合）
- **システム情報** - 負荷平均、プロセス数、スワップ使用量、カーネルバージョン、稼働時間、画面の明るさ
- **多言語サポート** - メニューから言語を選択（7言語対応）

### インタラクティブ機能

- 任意のカードを**クリック**して、対応するシステムアプリを開く（アクティビティモニタ、ディスクユーティリティ、システム設定など）
- メニューバーアイコンを**右クリック**して、設定と言語選択のクイックメニューを表示

## 要件

- macOS 12.0（Monterey）以降
- Apple SiliconまたはIntel Mac

## インストール

> **公証について：** SystemPulseは現在Appleによって公証されていません。公証とは、配布前にアプリをマルウェアスキャンするAppleのセキュリティプロセスです。これがないと、macOSは初回起動時に警告を表示します。SystemPulseのようなオープンソースアプリでは、コードを自分で確認できるため、これをバイパスしても安全です。公証は将来のリリースで予定されています。

### オプション1：Homebrew（推奨）

```bash
brew tap bluewave-labs/systempulse
brew install --cask systempulse
```

初回起動時、アプリを右クリック → 開く → 確認。または実行：`xattr -cr /Applications/SystemPulse.app`

### オプション2：DMGをダウンロード

1. [Releases](https://github.com/bluewave-labs/systempulse/releases)から最新のDMGをダウンロード
2. DMGを開き、SystemPulseをアプリケーションにドラッグ
3. 初回起動時、右クリック → 開く → 確認（上記の公証に関する注意を参照）

### オプション3：ソースからビルド

1. リポジトリをクローン：
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. アプリをビルド：
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. 実行：
   ```bash
   ./SystemPulse
   ```

### オプション4：アプリバンドルを作成（オプション）

SystemPulseを正式なmacOSアプリとして表示したい場合：

1. アプリ構造を作成：
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. `SystemPulse.app/Contents/Info.plist`を作成：
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
       <string>12.0</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

3. アプリケーションフォルダに移動（オプション）：
   ```bash
   mv SystemPulse.app /Applications/
   ```

### オプション5：Automatorで実行

この方法により、SystemPulseはターミナルから独立して実行されるため、ターミナルを閉じた後も動作し続けます。

1. まずSystemPulseをビルド（上記のオプション1を参照）

2. **Automator**を開く（Spotlightで検索）

3. **新規書類**をクリックし、**アプリケーション**を選択

4. 検索バーに「シェルスクリプトを実行」と入力し、ワークフローエリアにドラッグ

5. デフォルトのテキストをSystemPulseバイナリへのフルパスに置き換え：
   ```bash
   /path/to/systempulse/SystemPulse
   ```
   例えば、ホームフォルダにクローンした場合：
   ```bash
   ~/systempulse/SystemPulse
   ```

6. **ファイル** > **保存**に移動し、アプリケーションフォルダに「SystemPulse」として保存

7. 保存したAutomatorアプリをダブルクリックしてSystemPulseを実行

**ヒント：** SystemPulseをログイン項目に追加して、起動時に自動的に開始できます：
1. **システム設定** > **一般** > **ログイン項目**を開く
2. **+**をクリックし、SystemPulse Automatorアプリを選択

## 使用方法

実行すると、SystemPulseはメニューバーにCPUとメモリの使用状況を表示します。

- メニューバー項目を**左クリック**して詳細パネルを開く
- **右クリック**で設定、言語選択、終了オプションのクイックメニューを表示
- カードを**クリック**して関連するシステムアプリを開く

### 言語の変更

1. メニューバーのSystemPulseアイコンを右クリック
2. メニューから**言語**を選択
3. サブメニューからお好みの言語を選択

## 技術的詳細

SystemPulseは正確なメトリクスのためにネイティブmacOS APIを使用：

- **CPU**：`host_processor_info()` Mach API
- **メモリ**：`host_statistics64()` Mach API
- **GPU**：IOKit `IOAccelerator`サービス
- **ネットワーク**：インターフェース統計用の`getifaddrs()`
- **バッテリー**：IOKitからの`IOPSCopyPowerSourcesInfo()`
- **温度/ファン**：IOKit経由のSMC（System Management Controller）

## 貢献

貢献を歓迎します！お気軽にプルリクエストを送信してください。

### 翻訳の追加

SystemPulseは新しい言語を簡単に追加できます。新しい言語を追加するには：

1. `Language` enumに新しいケースを追加
2. `L10n` structのすべての文字列に翻訳を追加
3. プルリクエストを送信

## ライセンス

MITライセンス - 詳細は[LICENSE](LICENSE)を参照してください。

## 謝辞

ネイティブmacOSパフォーマンスのためにSwiftとAppKitで構築されています。
