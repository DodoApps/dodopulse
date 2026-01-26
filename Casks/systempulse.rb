cask "systempulse" do
  version "1.0.0"
  sha256 "REPLACE_WITH_SHA256_AFTER_UPLOAD"

  url "https://github.com/bluewave-labs/systempulse/releases/download/v#{version}/SystemPulse-#{version}.dmg"
  name "SystemPulse"
  desc "Lightweight macOS menu bar system monitor"
  homepage "https://github.com/bluewave-labs/systempulse"

  # Requires macOS 12.0 Monterey or later
  depends_on macos: ">= :monterey"

  app "SystemPulse.app"

  zap trash: [
    "~/Library/Preferences/com.bluewave-labs.systempulse.plist",
  ]

  caveats <<~EOS
    SystemPulse is not notarized. On first launch, you may need to:
    1. Right-click the app and select "Open"
    2. Click "Open" in the security dialog

    Or run: xattr -cr /Applications/SystemPulse.app
  EOS
end
