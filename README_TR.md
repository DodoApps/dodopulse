# DodoPulse

🌍 **7 dilde yerelleştirildi:** 🇺🇸 [English](README.md) | 🇹🇷 Türkçe | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

Gerçek zamanlı sistem metriklerini güzel mini grafiklerle gösteren hafif, yerli bir macOS menü çubuğu uygulaması.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
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

## Ücretli Alternatiflerle Karşılaştırma

| Özellik | DodoPulse | iStat Menus | TG Pro | Sensei |
|---------|-----------|-------------|--------|--------|
| **Fiyat** | Ücretsiz | ~$14 | $10 | $29 |
| **CPU izleme** | ✅ | ✅ | ✅ | ✅ |
| **GPU izleme** | ✅ | ✅ | ✅ | ✅ |
| **Bellek izleme** | ✅ | ✅ | ❌ | ✅ |
| **Ağ izleme** | ✅ Çoklu arayüz | ✅ Uygulama bazlı | ❌ | ❌ |
| **Disk izleme** | ✅ | ✅ | ✅ | ✅ |
| **Pil izleme** | ✅ | ✅ + Bluetooth | ✅ | ✅ |
| **Fan kontrolü** | ❌ | ✅ | ✅ | ✅ |
| **Hava durumu** | ❌ | ✅ | ❌ | ❌ |
| **Optimizasyon araçları** | ❌ | ❌ | ❌ | ✅ |
| **Açık kaynak** | ✅ | ❌ | ❌ | ❌ |
| **Tek dosya** | ✅ (~2000 satır) | ❌ | ❌ | ❌ |

**Neden DodoPulse?** Ücretsiz, açık kaynak, hafif (~%1-2 CPU), gizlilik odaklı (analitik yok) ve denetlemesi/değiştirmesi kolay.

## Gereksinimler

- macOS 12.0 (Monterey) veya üzeri
- Apple Silicon veya Intel Mac

## Kurulum

> **Notarizasyon hakkında:** DodoPulse şu anda Apple tarafından notarize edilmemiştir. Notarizasyon, Apple'ın uygulamaları dağıtımdan önce kötü amaçlı yazılım için tarayan güvenlik sürecidir. Bu olmadan, macOS "uygulama hasarlı" veya "açılamıyor" gibi uyarılar gösterebilir. Kodu kendiniz inceleyebileceğiniz DodoPulse gibi açık kaynak uygulamalar için bunu atlamak güvenlidir. **Çözüm:** Terminal'de `xattr -cr /Applications/DodoPulse.app` komutunu çalıştırın, ardından uygulamayı açın. Notarizasyon gelecek bir sürüm için planlanmaktadır.

### Seçenek 1: Homebrew (önerilen)

```bash
brew tap dodoapps/tap
brew install --cask dodopulse
```

İlk açılışta, uygulamaya sağ tıklayın → Aç → onaylayın. Veya çalıştırın: `xattr -cr /Applications/DodoPulse.app`

### Seçenek 2: DMG İndir

1. [Releases](https://github.com/dodoapps/dodopulse/releases) sayfasından en son DMG'yi indirin
2. DMG'yi açın ve DodoPulse'ı Uygulamalar'a sürükleyin
3. İlk açılışta, sağ tıklayın → Aç → onaylayın (yukarıdaki notarizasyon notuna bakın)

### Seçenek 3: Kaynaktan derleme

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/dodoapps/dodopulse.git
   cd dodopulse
   ```

2. Uygulamayı derleyin:
   ```bash
   swiftc -O -o DodoPulse DodoPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Çalıştırın:
   ```bash
   ./DodoPulse
   ```

### Seçenek 4: Uygulama paketi oluşturma (isteğe bağlı)

DodoPulse'ın düzgün bir macOS uygulaması olarak görünmesini istiyorsanız:

1. Uygulama yapısını oluşturun:
   ```bash
   mkdir -p DodoPulse.app/Contents/MacOS
   cp DodoPulse DodoPulse.app/Contents/MacOS/
   ```

2. `DodoPulse.app/Contents/Info.plist` dosyasını oluşturun:
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

3. Uygulamalar klasörüne taşıyın (isteğe bağlı):
   ```bash
   mv DodoPulse.app /Applications/
   ```

### Seçenek 5: Automator ile çalıştırma

Bu yöntem, DodoPulse'ın Terminal'den bağımsız çalışmasını sağlar, böylece Terminal'i kapattıktan sonra bile çalışmaya devam eder.

1. Önce DodoPulse'ı derleyin (yukarıdaki Seçenek 1'e bakın)

2. **Automator**'ı açın (Spotlight'ta arayın)

3. **Yeni Belge**'ye tıklayın ve **Uygulama**'yı seçin

4. Arama çubuğuna "Kabuk Betiği Çalıştır" yazın ve iş akışı alanına sürükleyin

5. Varsayılan metni DodoPulse binary'nizin tam yolu ile değiştirin:
   ```bash
   /path/to/dodopulse/DodoPulse
   ```
   Örneğin, ana klasörünüze klonladıysanız:
   ```bash
   ~/dodopulse/DodoPulse
   ```

6. **Dosya** > **Kaydet**'e gidin ve Uygulamalar klasörünüze "DodoPulse" olarak kaydedin

7. DodoPulse'ı çalıştırmak için kaydedilen Automator uygulamasına çift tıklayın

**İpucu:** DodoPulse'ı açılışta otomatik başlatmak için Giriş Öğelerinize ekleyebilirsiniz:
1. **Sistem Ayarları** > **Genel** > **Giriş Öğeleri**'ni açın
2. **+**'ya tıklayın ve DodoPulse Automator uygulamanızı seçin

## Kullanım

Çalıştırıldığında, DodoPulse menü çubuğunuzda CPU ve bellek kullanımını gösteren bir simge olarak görünür.

- Ayrıntılı paneli açmak için menü çubuğu öğesine **sol tıklayın**
- Ayarlar, dil seçimi ve çıkış seçeneği olan hızlı menü için **sağ tıklayın**
- İlgili sistem uygulamasını açmak için bir karta **tıklayın**

### Dil değiştirme

1. Menü çubuğundaki DodoPulse simgesine sağ tıklayın
2. Menüden **Dil**'i seçin
3. Alt menüden tercih ettiğiniz dili seçin

## Teknik detaylar

DodoPulse, doğru metrikler için yerli macOS API'lerini kullanır:

- **CPU**: `host_processor_info()` Mach API
- **Bellek**: `host_statistics64()` Mach API
- **GPU**: IOKit `IOAccelerator` servisi
- **Ağ**: Arayüz istatistikleri için `getifaddrs()`
- **Pil**: IOKit'ten `IOPSCopyPowerSourcesInfo()`
- **Sıcaklık/Fanlar**: IOKit aracılığıyla SMC (Sistem Yönetim Denetleyicisi)

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen bir pull request göndermekten çekinmeyin.

### Çeviri ekleme

DodoPulse yeni dillerin kolayca eklenmesini destekler. Yeni bir dil eklemek için:

1. `Language` enum'una yeni bir case ekleyin
2. `L10n` struct'ındaki tüm stringler için çeviri ekleyin
3. Bir pull request gönderin

## Lisans

MIT Lisansı - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## KDE Plasma Desteği

DodoPulse artık Linux kullanıcıları için **KDE Plasma widget'ı** olarak da mevcut!

Güzel sparkline grafikleriyle aynı sistem izleme özelliklerini sunar:
- Gerçek zamanlı grafiklerle CPU, Bellek, GPU izleme
- Oturum toplamlarıyla ağ hızları
- Harici disk algılama ile disk kullanımı
- Pil durumu ve sistem bilgisi

**Kurulum:**
```bash
kpackagetool6 -t Plasma/Applet -i dodopulse.plasmoid
```

Daha fazla detay için bkz. [KDE/README_TR.md](KDE/README_TR.md)

## GNOME Shell Desteği

DodoPulse artık bir **GNOME Shell eklentisi** olarak da mevcut (GNOME 43 → 51):
- Üst çubukta işlemci ve bellek kullanımı, isteğe bağlı ağ hızı
- Gerçek zamanlı grafiklerle İşlemci, Bellek, GPU ve Ağ kartları
- Harici disk algılama ile disk kullanımı, pil durumu ve sistem bilgisi

```bash
cd GNOME
./install.sh
gnome-extensions enable dodopulse@dodoapps.com
```

Daha fazla detay için bkz. [GNOME/README_TR.md](GNOME/README_TR.md)

## Teşekkürler

Yerli macOS performansı için Swift ve AppKit ile geliştirilmiştir.
