# DodoPulse GNOME Shell Eklentisi

GNOME üst çubuğu için mini grafikli, hafif bir sistem izleyici.

![GNOME Shell](https://img.shields.io/badge/GNOME_Shell-43%20→%2051-blue)
![License](https://img.shields.io/badge/License-MIT-green)

🇺🇸 [English](README.md)

## Özellikler

- **Üst çubuk göstergesi** - İşlemci ve bellek kullanım çubukları, isteğe bağlı ağ hızı
- **İşlemci izleme** - Kullanım, sıcaklık, frekans, çekirdek sayısı ve model, geçmiş grafiğiyle
- **Bellek izleme** - Kullanılan/toplam bellek, geçmiş grafiğiyle
- **GPU izleme** - Kullanım, sıcaklık ve VRAM (NVIDIA, AMD), frekansa dayalı yük (Intel)
- **Ağ izleme** - İndirme/yükleme hızları, oturum toplamları, yerel ve genel IP, geçmiş grafiğiyle
- **Disk izleme** - Kök disk kullanımı ve modeli, ayrıca diğer bağlı sürücüler (örn. `/home`, `/run/media/...`)
- **Pil izleme** - Şarj seviyesi, durum, kalan süre, güç tüketimi (yalnızca dizüstü)
- **Sistem bilgisi** - Yük ortalaması, süreç sayısı, takas alanı, çekirdek sürümü, çalışma süresi
- **Karta tıklayın**, ilgili uygulama açılsın (Sistem İzleyici, Disk Kullanım Analizcisi, Ayarlar → Ağ/Güç)
- **Ayarlar penceresi** - Güncelleme aralığı, üst çubuktaki konum, görünür bölümler
- **Yerelleştirme** - İngilizce ve Türkçe (sistem dilini takip eder)

## Desteklenen Sürümler

GNOME Shell 45 ile eklentiler ES modüllerine geçti. Bu nedenle DodoPulse aynı kaynaktan üretilen iki sürümle gelir:

| GNOME Shell | Sürüm | Modül sistemi |
|-------------|-------|---------------|
| 43, 44 | `legacy` | `imports.*` |
| 45 – 51 | `esm` | ES modülleri |

`install.sh` GNOME Shell sürümünüzü algılar ve uygun sürümü otomatik olarak kurar.

## Gereksinimler

- GNOME Shell 43 veya üstü
- `glib-compile-schemas` ve `zip` (derleme için)
- İsteğe bağlı:
  - NVIDIA GPU verileri için `nvidia-smi`
  - GPU adı için `lspci` (pciutils)
  - Genel IP adresi için `curl`
  - Sıcaklıklar için `lm-sensors` / çekirdek hwmon sürücüleri

## Kurulum

### Kurulum betiği (önerilen)

```bash
cd GNOME
./install.sh
```

Sistem geneline kurulum için:

```bash
sudo ./install.sh --system
```

Ardından GNOME Shell'i yeniden yükleyin:

- **X11:** `Alt+F2` tuşlayın, `r` yazıp Enter'a basın
- **Wayland:** oturumu kapatıp yeniden açın

Eklentiyi etkinleştirin:

```bash
gnome-extensions enable dodopulse@dodoapps.com
```

### Zip dosyasından kurulum

```bash
cd GNOME
./build.sh                 # iki sürümü de dist/ dizinine derler
gnome-extensions install --force dist/dodopulse@dodoapps.com.esm.shell-extension.zip     # GNOME 45+
gnome-extensions install --force dist/dodopulse@dodoapps.com.legacy.shell-extension.zip  # GNOME 43/44
```

## Yapılandırma

Ayarları açılır penceredeki **Ayarlar** düğmesinden açabilir ya da şu komutu çalıştırabilirsiniz:

```bash
gnome-extensions prefs dodopulse@dodoapps.com
```

- **Güncelleme aralığı** - 500 ms ile 10 sn arası
- **Üst çubuk konumu** - sol, orta veya sağ
- **Üst çubuk öğeleri** - işlemci, bellek, ağ hızı
- **Açılır pencere bölümleri** - işlemci, bellek, GPU, ağ, diskler, pil, sistem
- **Sıcaklıkları göster**
- **Genel IP adresini göster** - her 30 dakikada bir `api.ipify.org` sorgulanır. DodoPulse'ın hiç internete çıkmamasını istiyorsanız kapatın.

## Kaldırma

```bash
cd GNOME
./uninstall.sh
```

## Teknik Detaylar

DodoPulse sistem verilerini şu kaynaklardan okur:

- **İşlemci**: `/proc/stat`, `/proc/cpuinfo`, `/sys/devices/system/cpu/cpu*/cpufreq/`
- **Bellek**: `/proc/meminfo`
- **Ağ**: `/proc/net/dev` (loopback, Docker ve sanal köprüler hariç), `ip route`
- **Disk**: `df`, `lsblk`, `findmnt`
- **Sıcaklık**: `/sys/class/hwmon/` (coretemp, k10temp, zenpower...), `/sys/class/thermal/`
- **GPU**:
  - NVIDIA: `nvidia-smi`
  - AMD: `/sys/class/drm/card*/device/gpu_busy_percent`
  - Intel: `/sys/class/drm/card*/gt_act_freq_mhz` / `gt_max_freq_mhz`
- **Pil**: `/sys/class/power_supply/`

`/proc` ve `/sys` dosyaları doğrudan okunur. Harici komutlar asenkron çalıştığı için GNOME Shell'i bloklamaz. Açılır penceredeki öğeler yalnızca menü açıkken güncellenir.

## Sorun Giderme

### Eklenti görünmüyor

```bash
gnome-extensions info dodopulse@dodoapps.com
journalctl -f -o cat /usr/bin/gnome-shell
```

Wayland'de yeni bir eklenti ancak oturumu kapatıp açtıktan sonra algılanır.

### Sıcaklık görünmüyor

```bash
sudo apt install lm-sensors   # Debian/Ubuntu/Pardus
sudo sensors-detect
```

## Lisans

MIT Lisansı - detaylar için [LICENSE](../LICENSE) dosyasına bakın.

---

[DodoPulse](https://github.com/dodoapps/dodopulse) projesinin bir parçasıdır.
