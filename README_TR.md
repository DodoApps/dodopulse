# SystemPulse

🌍 **7 dilde yerelleştirildi:** 🇺🇸 [English](README.md) | 🇹🇷 Türkçe | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

Gerçek zamanlı sistem metriklerini güzel mini grafiklerle gösteren hafif, yerli bir macOS menü çubuğu uygulaması.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Lisans](https://img.shields.io/badge/Lisans-MIT-green)

## Özellikler

- **CPU izleme** - Kullanım yüzdesi, sıcaklık, frekans (Intel), çekirdek başına takip ve geçmiş grafiği
- **Bellek izleme** - Kullanılan/boş bellek, aktif/wired/sıkıştırılmış dağılımı
- **GPU izleme** - Kullanım yüzdesi, sıcaklık, ekran yenileme hızı (Hz)
- **Ağ izleme** - İndirme/yükleme hızları, yerel ve genel IP, oturum toplamları
- **Disk izleme** - Kullanım yüzdesi, boş alan, SSD sağlığı (varsa)
- **Pil izleme** - Şarj seviyesi, şarj durumu, kalan süre, güç tüketimi
- **Fan izleme** - Her fan için RPM (varsa)
- **Sistem bilgisi** - Yük ortalaması, işlem sayısı, swap kullanımı, kernel sürümü, çalışma süresi, ekran parlaklığı
- **Çoklu dil desteği** - Menüden dilinizi seçin (7 dil mevcut)

### Etkileşimli özellikler

- İlgili sistem uygulamasını açmak için herhangi bir karta **tıklayın** (Etkinlik Monitörü, Disk İzlencesi, Sistem Ayarları vb.)
- Ayarlar ve dil seçimi olan hızlı menü için menü çubuğu simgesine **sağ tıklayın**

## Gereksinimler

- macOS 12.0 (Monterey) veya üzeri
- Apple Silicon veya Intel Mac

## Kurulum

> **Notarizasyon hakkında:** SystemPulse şu anda Apple tarafından notarize edilmemiştir. Notarizasyon, Apple'ın uygulamaları dağıtımdan önce kötü amaçlı yazılım için tarayan güvenlik sürecidir. Bu olmadan, macOS ilk açılışta bir uyarı gösterir. Kodu kendiniz inceleyebileceğiniz SystemPulse gibi açık kaynak uygulamalar için bunu atlamak güvenlidir. Notarizasyon gelecek bir sürüm için planlanmaktadır.

### Seçenek 1: Homebrew (önerilen)

```bash
brew tap bluewave-labs/systempulse
brew install --cask systempulse
```

İlk açılışta, uygulamaya sağ tıklayın → Aç → onaylayın. Veya çalıştırın: `xattr -cr /Applications/SystemPulse.app`

### Seçenek 2: DMG İndir

1. [Releases](https://github.com/bluewave-labs/systempulse/releases) sayfasından en son DMG'yi indirin
2. DMG'yi açın ve SystemPulse'ı Uygulamalar'a sürükleyin
3. İlk açılışta, sağ tıklayın → Aç → onaylayın (yukarıdaki notarizasyon notuna bakın)

### Seçenek 3: Kaynaktan derleme

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. Uygulamayı derleyin:
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Çalıştırın:
   ```bash
   ./SystemPulse
   ```

### Seçenek 4: Uygulama paketi oluşturma (isteğe bağlı)

SystemPulse'ın düzgün bir macOS uygulaması olarak görünmesini istiyorsanız:

1. Uygulama yapısını oluşturun:
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. `SystemPulse.app/Contents/Info.plist` dosyasını oluşturun:
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

3. Uygulamalar klasörüne taşıyın (isteğe bağlı):
   ```bash
   mv SystemPulse.app /Applications/
   ```

### Seçenek 5: Automator ile çalıştırma

Bu yöntem, SystemPulse'ın Terminal'den bağımsız çalışmasını sağlar, böylece Terminal'i kapattıktan sonra bile çalışmaya devam eder.

1. Önce SystemPulse'ı derleyin (yukarıdaki Seçenek 1'e bakın)

2. **Automator**'ı açın (Spotlight'ta arayın)

3. **Yeni Belge**'ye tıklayın ve **Uygulama**'yı seçin

4. Arama çubuğuna "Kabuk Betiği Çalıştır" yazın ve iş akışı alanına sürükleyin

5. Varsayılan metni SystemPulse binary'nizin tam yolu ile değiştirin:
   ```bash
   /path/to/systempulse/SystemPulse
   ```
   Örneğin, ana klasörünüze klonladıysanız:
   ```bash
   ~/systempulse/SystemPulse
   ```

6. **Dosya** > **Kaydet**'e gidin ve Uygulamalar klasörünüze "SystemPulse" olarak kaydedin

7. SystemPulse'ı çalıştırmak için kaydedilen Automator uygulamasına çift tıklayın

**İpucu:** SystemPulse'ı açılışta otomatik başlatmak için Giriş Öğelerinize ekleyebilirsiniz:
1. **Sistem Ayarları** > **Genel** > **Giriş Öğeleri**'ni açın
2. **+**'ya tıklayın ve SystemPulse Automator uygulamanızı seçin

## Kullanım

Çalıştırıldığında, SystemPulse menü çubuğunuzda CPU ve bellek kullanımını gösteren bir simge olarak görünür.

- Ayrıntılı paneli açmak için menü çubuğu öğesine **sol tıklayın**
- Ayarlar, dil seçimi ve çıkış seçeneği olan hızlı menü için **sağ tıklayın**
- İlgili sistem uygulamasını açmak için bir karta **tıklayın**

### Dil değiştirme

1. Menü çubuğundaki SystemPulse simgesine sağ tıklayın
2. Menüden **Dil**'i seçin
3. Alt menüden tercih ettiğiniz dili seçin

## Teknik detaylar

SystemPulse, doğru metrikler için yerli macOS API'lerini kullanır:

- **CPU**: `host_processor_info()` Mach API
- **Bellek**: `host_statistics64()` Mach API
- **GPU**: IOKit `IOAccelerator` servisi
- **Ağ**: Arayüz istatistikleri için `getifaddrs()`
- **Pil**: IOKit'ten `IOPSCopyPowerSourcesInfo()`
- **Sıcaklık/Fanlar**: IOKit aracılığıyla SMC (Sistem Yönetim Denetleyicisi)

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen bir pull request göndermekten çekinmeyin.

### Çeviri ekleme

SystemPulse yeni dillerin kolayca eklenmesini destekler. Yeni bir dil eklemek için:

1. `Language` enum'una yeni bir case ekleyin
2. `L10n` struct'ındaki tüm stringler için çeviri ekleyin
3. Bir pull request gönderin

## Lisans

MIT Lisansı - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## Teşekkürler

Yerli macOS performansı için Swift ve AppKit ile geliştirilmiştir.
