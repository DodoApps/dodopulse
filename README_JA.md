# DodoPulse

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

## 有料代替アプリとの比較

| 機能 | DodoPulse | iStat Menus | TG Pro | Sensei |
|------|-----------|-------------|--------|--------|
| **価格** | 無料 | ~$14 | $10 | $29 |
| **CPU監視** | ✅ | ✅ | ✅ | ✅ |
| **GPU監視** | ✅ | ✅ | ✅ | ✅ |
| **メモリ監視** | ✅ | ✅ | ❌ | ✅ |
| **ネットワーク監視** | ✅ マルチインターフェース | ✅ アプリ別 | ❌ | ❌ |
| **ディスク監視** | ✅ | ✅ | ✅ | ✅ |
| **バッテリー監視** | ✅ | ✅ + Bluetooth | ✅ | ✅ |
| **ファン制御** | ❌ | ✅ | ✅ | ✅ |
| **天気** | ❌ | ✅ | ❌ | ❌ |
| **最適化ツール** | ❌ | ❌ | ❌ | ✅ |
| **オープンソース** | ✅ | ❌ | ❌ | ❌ |
| **単一ファイル** | ✅ (~2000行) | ❌ | ❌ | ❌ |

**なぜDodoPulse？** 無料、オープンソース、軽量（CPU ~1-2%）、プライバシー重視（分析なし）、監査・修正が容易。

## 要件

- macOS 12.0（Monterey）以降
- Apple SiliconまたはIntel Mac

## インストール

> **公証について：** DodoPulseは現在Appleによって公証されていません。公証とは、配布前にアプリをマルウェアスキャンするAppleのセキュリティプロセスです。これがないと、macOSは「アプリが破損しています」や「開けません」などの警告を表示することがあります。DodoPulseのようなオープンソースアプリでは、コードを自分で確認できるため、これをバイパスしても安全です。**解決方法：** ターミナルで `xattr -cr /Applications/DodoPulse.app` を実行してから、アプリを開いてください。公証は将来のリリースで予定されています。

### オプション1：Homebrew（推奨）

```bash
brew tap dodoapps/tap
brew install --cask dodopulse
```

初回起動時、アプリを右クリック → 開く → 確認。または実行：`xattr -cr /Applications/DodoPulse.app`

### オプション2：DMGをダウンロード

1. [Releases](https://github.com/dodoapps/dodopulse/releases)から最新のDMGをダウンロード
2. DMGを開き、DodoPulseをアプリケーションにドラッグ
3. 初回起動時、右クリック → 開く → 確認（上記の公証に関する注意を参照）

### オプション3：ソースからビルド

1. リポジトリをクローン：
   ```bash
   git clone https://github.com/dodoapps/dodopulse.git
   cd dodopulse
   ```

2. アプリをビルド：
   ```bash
   swiftc -O -o DodoPulse DodoPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. 実行：
   ```bash
   ./DodoPulse
   ```

### オプション4：アプリバンドルを作成（オプション）

DodoPulseを正式なmacOSアプリとして表示したい場合：

1. アプリ構造を作成：
   ```bash
   mkdir -p DodoPulse.app/Contents/MacOS
   cp DodoPulse DodoPulse.app/Contents/MacOS/
   ```

2. `DodoPulse.app/Contents/Info.plist`を作成：
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>CFBundleExecutable</key>
       <string>DodoPulse</string>
       <key>CFBundleIdentifier</key>
       <string>com.bluewave.dodopulse</string>
       <key>CFBundleName</key>
       <string>DodoPulse</string>
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
   mv DodoPulse.app /Applications/
   ```

### オプション5：Automatorで実行

この方法により、DodoPulseはターミナルから独立して実行されるため、ターミナルを閉じた後も動作し続けます。

1. まずDodoPulseをビルド（上記のオプション1を参照）

2. **Automator**を開く（Spotlightで検索）

3. **新規書類**をクリックし、**アプリケーション**を選択

4. 検索バーに「シェルスクリプトを実行」と入力し、ワークフローエリアにドラッグ

5. デフォルトのテキストをDodoPulseバイナリへのフルパスに置き換え：
   ```bash
   /path/to/dodopulse/DodoPulse
   ```
   例えば、ホームフォルダにクローンした場合：
   ```bash
   ~/dodopulse/DodoPulse
   ```

6. **ファイル** > **保存**に移動し、アプリケーションフォルダに「DodoPulse」として保存

7. 保存したAutomatorアプリをダブルクリックしてDodoPulseを実行

**ヒント：** DodoPulseをログイン項目に追加して、起動時に自動的に開始できます：
1. **システム設定** > **一般** > **ログイン項目**を開く
2. **+**をクリックし、DodoPulse Automatorアプリを選択

## 使用方法

実行すると、DodoPulseはメニューバーにCPUとメモリの使用状況を表示します。

- メニューバー項目を**左クリック**して詳細パネルを開く
- **右クリック**で設定、言語選択、終了オプションのクイックメニューを表示
- カードを**クリック**して関連するシステムアプリを開く

### 言語の変更

1. メニューバーのDodoPulseアイコンを右クリック
2. メニューから**言語**を選択
3. サブメニューからお好みの言語を選択

## 技術的詳細

DodoPulseは正確なメトリクスのためにネイティブmacOS APIを使用：

- **CPU**：`host_processor_info()` Mach API
- **メモリ**：`host_statistics64()` Mach API
- **GPU**：IOKit `IOAccelerator`サービス
- **ネットワーク**：インターフェース統計用の`getifaddrs()`
- **バッテリー**：IOKitからの`IOPSCopyPowerSourcesInfo()`
- **温度/ファン**：IOKit経由のSMC（System Management Controller）

## 貢献

貢献を歓迎します！お気軽にプルリクエストを送信してください。

### 翻訳の追加

DodoPulseは新しい言語を簡単に追加できます。新しい言語を追加するには：

1. `Language` enumに新しいケースを追加
2. `L10n` structのすべての文字列に翻訳を追加
3. プルリクエストを送信

## ライセンス

MITライセンス - 詳細は[LICENSE](LICENSE)を参照してください。

## KDE Plasmaサポート

DodoPulseはLinuxユーザー向けの**KDE Plasmaウィジェット**としても利用可能です！

美しいスパークライングラフで同じシステム監視機能を提供：
- リアルタイムグラフでCPU、メモリ、GPU監視
- セッション合計付きネットワーク速度
- 外部ドライブ検出付きディスク使用量
- バッテリー状態とシステム情報

**インストール：**
```bash
kpackagetool6 -t Plasma/Applet -i dodopulse.plasmoid
```

詳細は[KDE/README.md](KDE/README.md)を参照

## 謝辞

ネイティブmacOSパフォーマンスのためにSwiftとAppKitで構築されています。
