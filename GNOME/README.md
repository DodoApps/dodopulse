# DodoPulse GNOME Shell Extension

A lightweight system monitor for the GNOME top bar with beautiful mini graphs.

![GNOME Shell](https://img.shields.io/badge/GNOME_Shell-43%20→%2051-blue)
![License](https://img.shields.io/badge/License-MIT-green)

🇹🇷 [Türkçe](README_TR.md)

## Features

- **Top bar indicator** - CPU and memory usage bars, optional network speed
- **CPU monitoring** - Usage, temperature, frequency, core count, model with history graph
- **Memory monitoring** - Used/total memory with history graph
- **GPU monitoring** - Utilization, temperature and VRAM (NVIDIA, AMD), frequency-based load (Intel)
- **Network monitoring** - Download/upload speeds, session totals, local & public IP with history graph
- **Disk monitoring** - Root disk usage and model, plus other mounted drives (e.g. `/home`, `/run/media/...`)
- **Battery monitoring** - Charge level, status, time remaining, power draw (laptops only)
- **System info** - Load average, process count, swap, kernel version, uptime
- **Click a card** to open the related app (System Monitor, Disk Usage Analyzer, Settings → Network/Power)
- **Preferences window** - Update interval, top bar position, visible sections
- **Localized** - English and Turkish (follows the system language)

## Supported Versions

GNOME Shell 45 switched extensions to ES modules, so DodoPulse ships two flavours built from the same sources:

| GNOME Shell | Flavour | Module system |
|-------------|---------|---------------|
| 43, 44 | `legacy` | `imports.*` |
| 45 – 51 | `esm` | ES modules |

`install.sh` detects your GNOME Shell version and installs the matching flavour automatically.

## Requirements

- GNOME Shell 43 or later
- `glib-compile-schemas` and `zip` (for building)
- Optional:
  - `nvidia-smi` for NVIDIA GPU metrics
  - `lspci` (pciutils) for the GPU name
  - `curl` for the public IP address
  - `lm-sensors` / kernel hwmon drivers for temperatures

## Installation

### Install script (recommended)

```bash
cd GNOME
./install.sh
```

For system-wide installation:

```bash
sudo ./install.sh --system
```

Then reload GNOME Shell:

- **X11:** press `Alt+F2`, type `r`, press Enter
- **Wayland:** log out and log back in

Enable the extension:

```bash
gnome-extensions enable dodopulse@dodoapps.com
```

### Install from zip

```bash
cd GNOME
./build.sh                 # builds both flavours into dist/
gnome-extensions install --force dist/dodopulse@dodoapps.com.esm.shell-extension.zip     # GNOME 45+
gnome-extensions install --force dist/dodopulse@dodoapps.com.legacy.shell-extension.zip  # GNOME 43/44
```

## Configuration

Open the preferences from the **Settings** button in the popup, or run:

```bash
gnome-extensions prefs dodopulse@dodoapps.com
```

- **Update interval** - 500 ms to 10 s
- **Top bar position** - left, center or right
- **Top bar items** - CPU, memory, network speed
- **Popup sections** - CPU, memory, GPU, network, disks, battery, system
- **Show temperatures**
- **Show public IP** - queries `api.ipify.org` every 30 minutes; turn it off to keep DodoPulse fully offline

## File Structure

```
GNOME/
├── build.sh              # Builds legacy + esm flavours into build/ and dist/
├── install.sh            # Detects GNOME version, builds and installs
├── uninstall.sh          # Removes the extension
└── src/
    ├── core.js           # Shared monitoring logic and UI
    ├── prefsCore.js      # Shared preferences window
    ├── stylesheet.css
    ├── metadata.json.in  # shell-version is filled in by build.sh
    ├── schemas/          # GSettings schema
    ├── legacy/           # GNOME 43/44 entry points (extension.js, prefs.js)
    └── esm/              # GNOME 45+ entry points (extension.js, prefs.js)
```

`core.js` and `prefsCore.js` contain no `import`/`export` statements; all GNOME libraries are passed in by the entry points. For the ESM flavour, `build.sh` appends the `export` line.

## Uninstallation

```bash
cd GNOME
./uninstall.sh
```

## Technical Details

DodoPulse reads system metrics from:

- **CPU**: `/proc/stat`, `/proc/cpuinfo`, `/sys/devices/system/cpu/cpu*/cpufreq/`
- **Memory**: `/proc/meminfo`
- **Network**: `/proc/net/dev` (loopback, Docker and virtual bridges excluded), `ip route`
- **Disk**: `df`, `lsblk`, `findmnt`
- **Temperature**: `/sys/class/hwmon/` (coretemp, k10temp, zenpower...), `/sys/class/thermal/`
- **GPU**:
  - NVIDIA: `nvidia-smi`
  - AMD: `/sys/class/drm/card*/device/gpu_busy_percent`
  - Intel: `/sys/class/drm/card*/gt_act_freq_mhz` / `gt_max_freq_mhz`
- **Battery**: `/sys/class/power_supply/`

`/proc` and `/sys` files are read directly; external commands run asynchronously, so they never block GNOME Shell. Popup widgets are only updated while the menu is open.

## Troubleshooting

### Extension does not appear

```bash
gnome-extensions info dodopulse@dodoapps.com
journalctl -f -o cat /usr/bin/gnome-shell
```

On Wayland, a new extension is only picked up after logging out and back in.

### Temperature not showing

```bash
sudo apt install lm-sensors   # Debian/Ubuntu/Pardus
sudo sensors-detect
```

## License

MIT License - see [LICENSE](../LICENSE) for details.

---

Part of the [DodoPulse](https://github.com/dodoapps/dodopulse) project.
