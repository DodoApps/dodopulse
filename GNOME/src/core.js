// DodoPulse GNOME Shell extension - shared core
//
// This file is shared by both extension flavours:
//   - legacy (GNOME 43/44): loaded through `Me.imports.core`, so only top-level
//     `var` declarations are visible to the importer.
//   - ESM (GNOME 45+): build.sh appends `export { DodoPulseExtension };`.
// It must therefore not contain any `import`/`export` statements; every GNOME
// library it needs is passed in through the `deps` object.

/* exported DodoPulseExtension */

const HISTORY_LENGTH = 60;
const SLOW_INTERVAL_MS = 3000;
const IP_REFRESH_TICKS = 10;           // local IP refreshed every 10 slow ticks
const PUBLIC_IP_REFRESH_MS = 30 * 60 * 1000;
const GB = 1073741824;

const COLORS = {
    cpu: '#5B8DEF',
    mem: '#FF7359',
    gpu: '#F25990',
    net: '#40E68D',
    netUp: '#B266FF',
    disk: '#F2A60F',
    batt: '#4DE680',
    charging: '#60A5FA',
    temp: '#FF9933',
    warning: '#FFBF33',
    danger: '#FF5959',
    system: '#9980E6',
};

const STRINGS = {
    en: {
        cpu: 'CPU', memory: 'Memory', gpu: 'GPU', network: 'Network', disk: 'Disk',
        battery: 'Battery', charging: 'Charging', system: 'System',
        cores: 'cores', free: 'free of', session: 'Session', local: 'Local', public: 'Public',
        processes: 'Processes', load: 'Load', kernel: 'Kernel', swap: 'Swap',
        fullyCharged: 'Fully charged', pluggedIn: 'Plugged in', onBattery: 'On battery',
        left: 'left', untilFull: 'until full', notAvailable: 'Not available',
        settings: 'Settings', systemMonitor: 'System Monitor',
    },
    tr: {
        cpu: 'İşlemci', memory: 'Bellek', gpu: 'GPU', network: 'Ağ', disk: 'Disk',
        battery: 'Pil', charging: 'Şarj oluyor', system: 'Sistem',
        cores: 'çekirdek', free: 'boş /', session: 'Oturum', local: 'Yerel', public: 'Genel',
        processes: 'Süreçler', load: 'Yük', kernel: 'Çekirdek', swap: 'Takas',
        fullyCharged: 'Tam dolu', pluggedIn: 'Prize takılı', onBattery: 'Pilde',
        left: 'kaldı', untilFull: 'dolmasına', notAvailable: 'Kullanılamıyor',
        settings: 'Ayarlar', systemMonitor: 'Sistem İzleyici',
    },
};

function hexToRgb(hex) {
    const n = parseInt(hex.slice(1), 16);
    return [((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255];
}

function rgba(hex, alpha) {
    const [r, g, b] = hexToRgb(hex);
    return `rgba(${Math.round(r * 255)}, ${Math.round(g * 255)}, ${Math.round(b * 255)}, ${alpha})`;
}

function levelColor(value, base, warnAt, dangerAt) {
    if (value > dangerAt)
        return COLORS.danger;
    if (value > warnAt)
        return COLORS.warning;
    return base;
}

function formatSpeed(bps) {
    if (bps < 1024)
        return `${bps.toFixed(0)} B/s`;
    if (bps < 1048576)
        return `${(bps / 1024).toFixed(1)} KB/s`;
    return `${(bps / 1048576).toFixed(2)} MB/s`;
}

function formatSpeedShort(bps) {
    if (bps < 1024)
        return `${bps.toFixed(0)}B`;
    if (bps < 1048576)
        return `${(bps / 1024).toFixed(0)}K`;
    return `${(bps / 1048576).toFixed(1)}M`;
}

function formatBytes(b) {
    if (b < 1024)
        return `${b.toFixed(0)} B`;
    if (b < 1048576)
        return `${(b / 1024).toFixed(1)} KB`;
    if (b < GB)
        return `${(b / 1048576).toFixed(1)} MB`;
    return `${(b / GB).toFixed(2)} GB`;
}

function formatUptime(s) {
    const d = Math.floor(s / 86400);
    const h = Math.floor((s % 86400) / 3600);
    const m = Math.floor((s % 3600) / 60);
    if (d > 0)
        return `${d}d ${h}h ${m}m`;
    if (h > 0)
        return `${h}h ${m}m`;
    return `${m}m`;
}

function formatDuration(hours) {
    const h = Math.floor(hours);
    const m = Math.round((hours - h) * 60);
    return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

function pushHistory(history, value) {
    history.push(value);
    if (history.length > HISTORY_LENGTH)
        history.shift();
}

function roundedRect(cr, x, y, w, h, r) {
    r = Math.min(r, w / 2, h / 2);
    cr.newSubPath();
    cr.arc(x + w - r, y + r, r, -Math.PI / 2, 0);
    cr.arc(x + w - r, y + h - r, r, 0, Math.PI / 2);
    cr.arc(x + r, y + h - r, r, Math.PI / 2, Math.PI);
    cr.arc(x + r, y + r, r, Math.PI, 1.5 * Math.PI);
    cr.closePath();
}

var DodoPulseExtension = class {
    /**
     * @param {object} deps GNOME libraries: GLib, Gio, St, Clutter, Shell, Cairo,
     *   Main, PanelMenu, PopupMenu
     * @param {Gio.Settings} settings extension settings
     * @param {string} uuid extension uuid
     * @param {Function} openPrefs opens the preferences window
     */
    constructor(deps, settings, uuid, openPrefs) {
        this._d = deps;
        this._settings = settings;
        this._uuid = uuid;
        this._openPrefs = openPrefs;
        this._decoder = new TextDecoder('utf-8');

        const lang = (deps.GLib.get_language_names()[0] || 'en').toLowerCase();
        this._t = lang.startsWith('tr') ? STRINGS.tr : STRINGS.en;

        this._resetState();
    }

    _resetState() {
        this._s = {
            cpuUsage: 0, cpuTemp: 0, cpuCores: 0, cpuModel: '', cpuFreqGHz: 0,
            memUsage: 0, memUsedGB: 0, memTotalGB: 0, swapUsedGB: 0, swapTotalGB: 0,
            gpuUsage: 0, gpuTemp: 0, gpuName: '', gpuDetail: '', gpuAvailable: false,
            netIn: 0, netOut: 0, netSessionIn: 0, netSessionOut: 0,
            localIP: '—', publicIP: '—',
            disk: null, otherDisks: [], diskModel: '',
            battery: null,
            loadAvg: [0, 0, 0], processCount: 0, kernel: '', uptime: 0,
        };
        this._hist = {cpu: [], mem: [], gpu: [], net: []};
        for (let i = 0; i < HISTORY_LENGTH; i++) {
            for (const k in this._hist)
                this._hist[k].push(0);
        }
        this._prevCpu = null;
        this._prevNet = null;
        this._netBaseline = null;
        this._slowTicks = 0;
        this._busy = {};
    }

    // ── lifecycle ───────────────────────────────────────────────────────────

    enable() {
        const {Gio} = this._d;
        this._destroyed = false;
        this._cancellable = new Gio.Cancellable();
        this._procs = new Set();

        this._detectStatic();
        this._buildIndicator();

        this._settingsIds = [
            this._settings.connect('changed::panel-position', () => this._rebuildIndicator()),
            this._settings.connect('changed::update-interval', () => this._startFastTimer()),
            this._settings.connect('changed::show-public-ip', () => this._refreshPublicIP()),
            this._settings.connect('changed', () => this._applyVisibility()),
        ];

        this._fastTick();
        this._slowTick();
        this._refreshPublicIP();
        this._startFastTimer();

        const {GLib} = this._d;
        this._slowTimerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, SLOW_INTERVAL_MS, () => {
            this._slowTick();
            return GLib.SOURCE_CONTINUE;
        });
        this._publicIpTimerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, PUBLIC_IP_REFRESH_MS, () => {
            this._refreshPublicIP();
            return GLib.SOURCE_CONTINUE;
        });
    }

    destroy() {
        const {GLib} = this._d;
        this._destroyed = true;

        for (const id of ['_fastTimerId', '_slowTimerId', '_publicIpTimerId']) {
            if (this[id]) {
                GLib.source_remove(this[id]);
                this[id] = 0;
            }
        }
        if (this._settingsIds) {
            this._settingsIds.forEach(id => this._settings.disconnect(id));
            this._settingsIds = null;
        }
        if (this._cancellable) {
            this._cancellable.cancel();
            this._cancellable = null;
        }
        if (this._procs) {
            this._procs.forEach(p => {
                try {
                    p.force_exit();
                } catch (e) {}
            });
            this._procs = null;
        }

        this._destroyIndicator();
        this._settings = null;
    }

    _startFastTimer() {
        const {GLib} = this._d;
        if (this._fastTimerId)
            GLib.source_remove(this._fastTimerId);
        const interval = this._settings.get_int('update-interval');
        this._fastTimerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, interval, () => {
            this._fastTick();
            return GLib.SOURCE_CONTINUE;
        });
    }

    // ── helpers ─────────────────────────────────────────────────────────────

    _read(path) {
        try {
            const [ok, bytes] = this._d.GLib.file_get_contents(path);
            return ok ? this._decoder.decode(bytes) : null;
        } catch (e) {
            return null;
        }
    }

    _readInt(path) {
        const txt = this._read(path);
        if (txt === null)
            return null;
        const n = parseInt(txt.trim());
        return isNaN(n) ? null : n;
    }

    _exists(path) {
        return this._d.GLib.file_test(path, this._d.GLib.FileTest.EXISTS);
    }

    _listDir(path) {
        const {Gio} = this._d;
        const names = [];
        try {
            const en = Gio.File.new_for_path(path).enumerate_children(
                'standard::name', Gio.FileQueryInfoFlags.NONE, null);
            let info;
            while ((info = en.next_file(null)) !== null)
                names.push(info.get_name());
            en.close(null);
        } catch (e) {}
        return names.sort((a, b) => a.localeCompare(b, undefined, {numeric: true}));
    }

    _hasProgram(name) {
        return this._d.GLib.find_program_in_path(name) !== null;
    }

    /**
     * Runs a command asynchronously. Calls `callback(stdout)` with null on failure.
     * A command with the same key is never run twice concurrently.
     */
    _run(key, argv, callback) {
        const {Gio} = this._d;
        if (this._busy[key] || this._destroyed)
            return;
        this._busy[key] = true;
        let proc;
        try {
            proc = Gio.Subprocess.new(argv,
                Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE);
        } catch (e) {
            this._busy[key] = false;
            callback(null);
            return;
        }
        this._procs.add(proc);
        proc.communicate_utf8_async(null, this._cancellable, (p, res) => {
            if (this._destroyed)
                return;
            this._procs.delete(p);
            this._busy[key] = false;
            let out = null;
            try {
                const [, stdout] = p.communicate_utf8_finish(res);
                if (p.get_successful())
                    out = stdout;
            } catch (e) {
                return;
            }
            callback(out);
        });
    }

    _launch(target) {
        const {Shell, Gio} = this._d;
        this._button?.menu.close();
        const appSys = Shell.AppSystem.get_default();
        for (const id of target.apps || []) {
            const app = appSys.lookup_app(id);
            if (app) {
                app.activate();
                return;
            }
        }
        if (target.command && this._hasProgram(target.command[0])) {
            try {
                Gio.Subprocess.new(target.command, Gio.SubprocessFlags.NONE);
            } catch (e) {}
        }
    }

    // ── static detection (runs once on enable) ─────────────────────────────

    _detectStatic() {
        const {GLib} = this._d;
        const s = this._s;

        const osrelease = this._read('/proc/sys/kernel/osrelease');
        s.kernel = osrelease ? osrelease.trim() : '';
        s.cpuCores = GLib.get_num_processors();

        const cpuinfo = this._read('/proc/cpuinfo') || '';
        const m = cpuinfo.match(/^model name\s*:\s*(.+)$/m) ||
            cpuinfo.match(/^Hardware\s*:\s*(.+)$/m);
        if (m) {
            s.cpuModel = m[1].replace(/\((R|TM)\)/gi, '').replace(/\bCPU\b/, '')
                .replace(/@.*$/, '').replace(/\s+/g, ' ').trim();
        }

        this._cpuTempPath = this._detectCpuTempPath();
        this._detectGpu();
        this._batteryPath = this._detectBattery();

        // Walk up from the root filesystem (partition, LVM, LUKS...) to the physical disk
        this._run('rootsource', ['findmnt', '-nvo', 'SOURCE', '/'], src => {
            if (!src || !src.trim())
                return;
            this._run('diskmodel', ['lsblk', '-nsPo', 'TYPE,MODEL', src.trim()], out => {
                const m = out && out.match(/TYPE="disk"\s+MODEL="([^"]*)"/);
                if (m && m[1].trim())
                    s.diskModel = m[1].trim().replace(/\s+/g, ' ').substring(0, 28);
            });
        });
    }

    _detectCpuTempPath() {
        const base = '/sys/class/hwmon';
        const hwmons = this._listDir(base).map(h => ({
            path: `${base}/${h}`,
            name: (this._read(`${base}/${h}/name`) || '').trim(),
        }));
        const preferred = [
            ['coretemp', [/Package id 0/i]],
            ['k10temp', [/Tdie/i, /Tctl/i]],
            ['zenpower', [/Tdie/i, /Tctl/i]],
            ['cpu_thermal', []],
            ['soc_thermal', []],
            ['acpitz', []],
        ];
        for (const [name, labels] of preferred) {
            const hw = hwmons.find(h => h.name === name);
            if (!hw)
                continue;
            const temps = this._listDir(hw.path).filter(f => /^temp\d+_input$/.test(f));
            for (const re of labels) {
                const match = temps.find(f => {
                    const label = this._read(`${hw.path}/${f.replace('_input', '_label')}`);
                    return label && re.test(label);
                });
                if (match)
                    return `${hw.path}/${match}`;
            }
            if (temps.length > 0)
                return `${hw.path}/${temps[0]}`;
        }

        const tz = '/sys/class/thermal';
        for (const zone of this._listDir(tz).filter(z => z.startsWith('thermal_zone'))) {
            const type = (this._read(`${tz}/${zone}/type`) || '').trim();
            if (/x86_pkg_temp|cpu/i.test(type))
                return `${tz}/${zone}/temp`;
        }
        return null;
    }

    _detectGpu() {
        const s = this._s;
        this._gpu = {mode: 'none'};

        if (this._hasProgram('nvidia-smi')) {
            this._gpu = {mode: 'nvidia'};
            s.gpuAvailable = true;
        } else {
            const drm = '/sys/class/drm';
            const cards = this._listDir(drm).filter(c => /^card\d+$/.test(c));
            for (const card of cards) {
                const dev = `${drm}/${card}/device`;
                if (this._exists(`${dev}/gpu_busy_percent`)) {
                    const hwmon = this._listDir(`${dev}/hwmon`)[0];
                    this._gpu = {
                        mode: 'amd',
                        busy: `${dev}/gpu_busy_percent`,
                        temp: hwmon ? `${dev}/hwmon/${hwmon}/temp1_input` : null,
                        vramUsed: `${dev}/mem_info_vram_used`,
                        vramTotal: `${dev}/mem_info_vram_total`,
                    };
                    break;
                }
            }
            if (this._gpu.mode === 'none') {
                for (const card of cards) {
                    const candidates = [
                        [`${drm}/${card}/gt_act_freq_mhz`, `${drm}/${card}/gt_max_freq_mhz`],
                        [`${drm}/${card}/gt/gt0/rps_act_freq_mhz`, `${drm}/${card}/gt/gt0/rps_max_freq_mhz`],
                        [`${drm}/${card}/device/tile0/gt0/freq0/act_freq`, `${drm}/${card}/device/tile0/gt0/freq0/max_freq`],
                    ];
                    const found = candidates.find(([a, b]) => this._exists(a) && this._exists(b));
                    if (found) {
                        this._gpu = {mode: 'intel', act: found[0], max: found[1]};
                        break;
                    }
                }
            }
            s.gpuAvailable = this._gpu.mode !== 'none';
        }

        if (this._hasProgram('lspci')) {
            this._run('gpuname', ['lspci'], out => {
                if (!out || s.gpuName)
                    return;
                const lines = out.split('\n').filter(l => /VGA compatible|3D controller|Display controller/.test(l));
                const vendorRe = {nvidia: /NVIDIA/i, amd: /\bAMD\b|\bATI\b|Advanced Micro/i, intel: /Intel/i}[this._gpu.mode];
                const line = (vendorRe && lines.find(l => vendorRe.test(l))) || lines[0];
                if (line)
                    s.gpuName = this._cleanGpuName(line);
            });
        }
    }

    _cleanGpuName(line) {
        let desc = line.replace(/^.*?controller[^:]*:\s*/, '').replace(/\(rev [^)]*\)/, '').trim();
        let vendor = '';
        if (/NVIDIA/i.test(desc))
            vendor = 'NVIDIA';
        else if (/\bAMD\b|\bATI\b|Advanced Micro/i.test(desc))
            vendor = 'AMD';
        else if (/Intel/i.test(desc))
            vendor = 'Intel';
        const brackets = desc.match(/\[([^\]]+)\]/g);
        if (brackets) {
            const last = brackets[brackets.length - 1].slice(1, -1);
            if (!/^AMD\/ATI$/.test(last))
                desc = vendor ? `${vendor} ${last}` : last;
        } else {
            desc = desc.replace(/Corporation|Inc\.?|,/g, '').replace(/\s+/g, ' ').trim();
        }
        return desc.substring(0, 32);
    }

    _detectBattery() {
        const base = '/sys/class/power_supply';
        for (const ps of this._listDir(base)) {
            const type = (this._read(`${base}/${ps}/type`) || '').trim();
            const scope = (this._read(`${base}/${ps}/scope`) || '').trim();
            if (type === 'Battery' && scope !== 'Device' && this._exists(`${base}/${ps}/capacity`))
                return `${base}/${ps}`;
        }
        return null;
    }

    // ── sampling ────────────────────────────────────────────────────────────

    _fastTick() {
        this._sampleCpu();
        this._sampleMemory();
        this._sampleNetwork();
        this._sampleLoad();
        this._updatePanel();
        if (this._button?.menu.isOpen)
            this._updatePopup();
    }

    _slowTick() {
        this._sampleTemperature();
        this._sampleCpuFreq();
        this._sampleGpu();
        this._sampleBattery();
        this._sampleDisks();
        if (this._slowTicks % IP_REFRESH_TICKS === 0)
            this._sampleLocalIP();
        this._slowTicks++;
    }

    _sampleCpu() {
        const stat = this._read('/proc/stat');
        if (!stat)
            return;
        const line = stat.split('\n').find(l => l.startsWith('cpu '));
        if (!line)
            return;
        const p = line.trim().split(/\s+/).slice(1).map(v => parseInt(v) || 0);
        const [user, nice, sys, idle, iowait, irq, softirq, steal] = p;
        const idleAll = idle + iowait;
        const total = user + nice + sys + idleAll + irq + softirq + (steal || 0);
        if (this._prevCpu) {
            const dt = total - this._prevCpu.total;
            const di = idleAll - this._prevCpu.idle;
            if (dt > 0)
                this._s.cpuUsage = Math.max(0, Math.min(100, ((dt - di) / dt) * 100));
        }
        this._prevCpu = {total, idle: idleAll};
        pushHistory(this._hist.cpu, this._s.cpuUsage);
    }

    _sampleMemory() {
        const info = this._read('/proc/meminfo');
        if (!info)
            return;
        const val = key => {
            const m = info.match(new RegExp(`^${key}:\\s+(\\d+)`, 'm'));
            return m ? parseInt(m[1]) : 0;
        };
        const total = val('MemTotal');
        const avail = val('MemAvailable');
        const s = this._s;
        if (total > 0) {
            const used = total - avail;
            s.memUsage = (used / total) * 100;
            s.memUsedGB = used / 1048576;
            s.memTotalGB = total / 1048576;
        }
        s.swapTotalGB = val('SwapTotal') / 1048576;
        s.swapUsedGB = (val('SwapTotal') - val('SwapFree')) / 1048576;
        pushHistory(this._hist.mem, s.memUsage);
    }

    _sampleNetwork() {
        const dev = this._read('/proc/net/dev');
        if (!dev)
            return;
        let rx = 0, tx = 0;
        for (const line of dev.split('\n').slice(2)) {
            const idx = line.indexOf(':');
            if (idx < 0)
                continue;
            const iface = line.slice(0, idx).trim();
            if (/^(lo|veth|docker|br-|virbr|vnet|cni|flannel|kube)/.test(iface))
                continue;
            const p = line.slice(idx + 1).trim().split(/\s+/);
            rx += parseInt(p[0]) || 0;
            tx += parseInt(p[8]) || 0;
        }
        const now = this._d.GLib.get_monotonic_time() / 1e6;
        const s = this._s;
        if (this._prevNet) {
            const dt = now - this._prevNet.time;
            if (dt > 0) {
                s.netIn = Math.max(0, (rx - this._prevNet.rx) / dt);
                s.netOut = Math.max(0, (tx - this._prevNet.tx) / dt);
            }
        }
        if (!this._netBaseline || rx < this._netBaseline.rx || tx < this._netBaseline.tx)
            this._netBaseline = {rx, tx};
        s.netSessionIn = rx - this._netBaseline.rx;
        s.netSessionOut = tx - this._netBaseline.tx;
        this._prevNet = {rx, tx, time: now};
        pushHistory(this._hist.net, s.netIn + s.netOut);
    }

    _sampleLoad() {
        const s = this._s;
        const load = this._read('/proc/loadavg');
        if (load) {
            const p = load.trim().split(/\s+/);
            s.loadAvg = [parseFloat(p[0]) || 0, parseFloat(p[1]) || 0, parseFloat(p[2]) || 0];
            const procs = (p[3] || '').split('/');
            if (procs.length === 2)
                s.processCount = parseInt(procs[1]) || 0;
        }
        const up = this._read('/proc/uptime');
        if (up)
            s.uptime = parseFloat(up.split(' ')[0]) || 0;
    }

    _sampleTemperature() {
        if (!this._cpuTempPath)
            return;
        const t = this._readInt(this._cpuTempPath);
        if (t !== null) {
            const c = t > 1000 ? t / 1000 : t;
            if (c > 0 && c < 150)
                this._s.cpuTemp = c;
        }
    }

    _sampleCpuFreq() {
        let sum = 0, count = 0;
        for (let i = 0; i < this._s.cpuCores; i++) {
            const f = this._readInt(`/sys/devices/system/cpu/cpu${i}/cpufreq/scaling_cur_freq`);
            if (f !== null) {
                sum += f;
                count++;
            }
        }
        this._s.cpuFreqGHz = count > 0 ? sum / count / 1e6 : 0;
    }

    _sampleGpu() {
        const s = this._s;
        const g = this._gpu;
        if (g.mode === 'nvidia') {
            this._run('gpu', ['nvidia-smi',
                '--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name',
                '--format=csv,noheader,nounits'], out => {
                if (!out)
                    return;
                const p = out.split('\n')[0].split(',').map(v => v.trim());
                s.gpuUsage = parseFloat(p[0]) || 0;
                s.gpuTemp = parseFloat(p[1]) || 0;
                const used = parseFloat(p[2]), total = parseFloat(p[3]);
                if (total > 0)
                    s.gpuDetail = `VRAM ${(used / 1024).toFixed(1)} / ${(total / 1024).toFixed(0)} GB`;
                if (p[4])
                    s.gpuName = p[4].replace(/^NVIDIA\s*/, 'NVIDIA ').substring(0, 32);
            });
        } else if (g.mode === 'amd') {
            const busy = this._readInt(g.busy);
            if (busy !== null)
                s.gpuUsage = busy;
            if (g.temp) {
                const t = this._readInt(g.temp);
                if (t !== null)
                    s.gpuTemp = t / 1000;
            }
            const used = this._readInt(g.vramUsed), total = this._readInt(g.vramTotal);
            if (used !== null && total)
                s.gpuDetail = `VRAM ${(used / GB).toFixed(1)} / ${(total / GB).toFixed(0)} GB`;
        } else if (g.mode === 'intel') {
            const act = this._readInt(g.act), max = this._readInt(g.max);
            if (act !== null && max)
                s.gpuUsage = Math.min(100, (act * 100) / max);
            if (act !== null)
                s.gpuDetail = `${act} MHz`;
        }
        pushHistory(this._hist.gpu, s.gpuUsage);
    }

    _sampleBattery() {
        const path = this._batteryPath;
        if (!path) {
            this._s.battery = null;
            return;
        }
        const level = this._readInt(`${path}/capacity`);
        if (level === null) {
            this._s.battery = null;
            return;
        }
        const status = (this._read(`${path}/status`) || '').trim();

        // Time remaining: energy_* (µWh/µW) or charge_* (µAh/µA)
        let now = this._readInt(`${path}/energy_now`);
        let full = this._readInt(`${path}/energy_full`);
        let rate = this._readInt(`${path}/power_now`);
        if (now === null) {
            now = this._readInt(`${path}/charge_now`);
            full = this._readInt(`${path}/charge_full`);
            rate = this._readInt(`${path}/current_now`);
        }
        let hours = 0;
        if (rate && rate > 0 && now !== null) {
            if (status === 'Discharging')
                hours = now / rate;
            else if (status === 'Charging' && full)
                hours = (full - now) / rate;
        }
        const powerUW = this._readInt(`${path}/power_now`);
        this._s.battery = {
            level,
            status,
            hours: hours > 0 && hours < 48 ? hours : 0,
            watts: powerUW ? powerUW / 1e6 : 0,
        };
    }

    _sampleDisks() {
        this._run('disks', ['df', '-l', '-B1', '--output=source,size,used,avail,target',
            '-x', 'tmpfs', '-x', 'devtmpfs', '-x', 'squashfs', '-x', 'overlay',
            '-x', 'efivarfs', '-x', 'ramfs'], out => {
            if (!out)
                return;
            const s = this._s;
            const seen = new Set();
            const others = [];
            let root = null;
            for (const line of out.trim().split('\n').slice(1)) {
                const p = line.trim().split(/\s+/);
                if (p.length < 5)
                    continue;
                const [source, size, used, avail] = p;
                const mount = p.slice(4).join(' ');
                const t = parseInt(size) || 0;
                if (t <= 0)
                    continue;
                const entry = {
                    source,
                    mount,
                    usage: (parseInt(used) / t) * 100,
                    freeGB: (parseInt(avail) || 0) / GB,
                    totalGB: t / GB,
                };
                if (mount === '/') {
                    root = entry;
                    continue;
                }
                if (/^\/(boot|efi|snap|var|tmp|sys|proc|dev|run)(\/|$)/.test(mount) &&
                    !mount.startsWith('/run/media/'))
                    continue;
                if (t < GB || seen.has(source))
                    continue;
                seen.add(source);
                others.push(entry);
            }
            if (root)
                seen.add(root.source);
            s.disk = root;
            s.otherDisks = others.filter(d => !(root && d.source === root.source)).slice(0, 5);
            if (this._button?.menu.isOpen)
                this._updateDisks();
        });
    }

    _sampleLocalIP() {
        this._run('localip', ['ip', '-4', 'route', 'get', '1.1.1.1'], out => {
            const m = out && out.match(/\bsrc\s+(\d+\.\d+\.\d+\.\d+)/);
            this._s.localIP = m ? m[1] : '—';
        });
    }

    _refreshPublicIP() {
        if (!this._settings || !this._settings.get_boolean('show-public-ip') || !this._hasProgram('curl')) {
            this._s.publicIP = '—';
            return;
        }
        this._run('publicip', ['curl', '-s', '--max-time', '5', 'https://api.ipify.org'], out => {
            const ip = out ? out.trim() : '';
            this._s.publicIP = /^[0-9a-fA-F.:]{3,45}$/.test(ip) ? ip : '—';
        });
    }

    // ── UI construction ─────────────────────────────────────────────────────

    _vbox(params = {}) {
        const {St, Clutter} = this._d;
        const box = new St.BoxLayout(params);
        if (box.orientation !== undefined)
            box.orientation = Clutter.Orientation.VERTICAL;
        else
            box.vertical = true;
        return box;
    }

    _hbox(params = {}) {
        return new this._d.St.BoxLayout(params);
    }

    _label(text, styleClass, extra = {}) {
        const {St, Clutter} = this._d;
        return new St.Label({text, style_class: styleClass, y_align: Clutter.ActorAlign.CENTER, ...extra});
    }

    _spacer() {
        return new this._d.St.Widget({x_expand: true});
    }

    _drawingArea(width, height, painter, expand = false) {
        const {St} = this._d;
        const area = new St.DrawingArea({
            style: `${expand ? '' : `width: ${width}px; `}height: ${height}px;`,
            x_expand: expand,
        });
        area.connect('repaint', a => {
            const cr = a.get_context();
            const [w, h] = a.get_surface_size();
            try {
                painter(cr, w, h);
            } finally {
                cr.$dispose();
            }
        });
        return area;
    }

    _sparkline(width, height, history, color, fixedMax) {
        const {Cairo} = this._d;
        const [r, g, b] = hexToRgb(color);
        return this._drawingArea(width, height, (cr, w, h) => {
            const vals = this._hist[history];
            let max = fixedMax || Math.max(...vals);
            if (max < 1)
                max = fixedMax || 1024;

            roundedRect(cr, 0, 0, w, h, 6);
            cr.setSourceRGBA(r, g, b, 0.10);
            cr.fill();

            const y = v => h - (Math.min(v, max) / max) * h * 0.85 - 2;
            const x = i => (i / (vals.length - 1)) * w;

            cr.moveTo(0, h);
            vals.forEach((v, i) => cr.lineTo(x(i), y(v)));
            cr.lineTo(w, h);
            cr.closePath();
            const grad = new Cairo.LinearGradient(0, 0, 0, h);
            grad.addColorStopRGBA(0, r, g, b, 0.4);
            grad.addColorStopRGBA(1, r, g, b, 0.05);
            cr.setSource(grad);
            cr.fill();

            cr.setSourceRGBA(r, g, b, 1);
            cr.setLineWidth(1.5);
            vals.forEach((v, i) => (i === 0 ? cr.moveTo(x(i), y(v)) : cr.lineTo(x(i), y(v))));
            cr.stroke();

            cr.arc(w - 2.5, y(vals[vals.length - 1]), 2.5, 0, 2 * Math.PI);
            cr.fill();
        });
    }

    _progressBar(height, getState, width = 0) {
        return this._drawingArea(width, height, (cr, w, h) => {
            const {fraction, color} = getState();
            roundedRect(cr, 0, 0, w, h, h / 2);
            cr.setSourceRGBA(0.5, 0.5, 0.5, 0.2);
            cr.fill();
            const fw = Math.max(0, Math.min(1, fraction)) * w;
            if (fw > 0) {
                const [r, g, b] = hexToRgb(color);
                roundedRect(cr, 0, 0, fw, h, h / 2);
                cr.setSourceRGBA(r, g, b, 1);
                cr.fill();
            }
        }, width === 0);
    }

    _verticalBar(getState) {
        return this._drawingArea(5, 16, (cr, w, h) => {
            const {fraction, color} = getState();
            const [r, g, b] = hexToRgb(color);
            roundedRect(cr, 0, 0, w, h, 2);
            cr.setSourceRGBA(r, g, b, 0.3);
            cr.fill();
            const fh = Math.max(0, Math.min(1, fraction)) * h;
            if (fh > 0) {
                roundedRect(cr, 0, h - fh, w, fh, 2);
                cr.setSourceRGBA(r, g, b, 1);
                cr.fill();
            }
        });
    }

    _card(color, target, small = false) {
        const {St} = this._d;
        const base = `border-color: ${rgba(color, small ? 0.2 : 0.3)};`;
        const bg = alpha => `background-color: ${rgba(color, alpha)}; ${base}`;
        const idle = small ? 0.05 : 0.10;
        const box = this._hbox({
            style_class: `dodopulse-card${small ? ' dodopulse-card-small' : ''}`,
            style: bg(idle),
            x_expand: true,
        });
        const button = new St.Button({
            child: box,
            x_expand: true,
            reactive: true,
            can_focus: true,
            track_hover: true,
        });
        button.connect('notify::hover', () => box.set_style(bg(button.hover ? idle + 0.08 : idle)));
        button.connect('clicked', () => this._launch(target));
        return {button, box};
    }

    _tempBadge() {
        return this._label('', 'dodopulse-badge', {
            style: `background-color: ${rgba(COLORS.temp, 0.15)};`,
            visible: false,
        });
    }

    _buildIndicator() {
        const {St, Clutter, Main, PanelMenu, PopupMenu} = this._d;
        const t = this._t;
        const s = this._s;

        this._button = new PanelMenu.Button(0.0, 'DodoPulse', false);
        this._button.add_style_class_name('dodopulse-button');

        // ── top bar ──
        const panel = this._hbox({style_class: 'dodopulse-panel', y_align: Clutter.ActorAlign.CENTER});
        this._panel = {};

        const cpuBox = this._hbox({style: 'spacing: 4px;'});
        this._panel.cpuBar = this._verticalBar(() => ({
            fraction: s.cpuUsage / 100,
            color: levelColor(s.cpuUsage, COLORS.cpu, 70, 90),
        }));
        this._panel.cpuLabel = this._label('0%', 'dodopulse-panel-label');
        cpuBox.add_child(this._panel.cpuBar);
        cpuBox.add_child(this._panel.cpuLabel);

        const memBox = this._hbox({style: 'spacing: 4px;'});
        this._panel.memBar = this._verticalBar(() => ({
            fraction: s.memUsage / 100,
            color: levelColor(s.memUsage, COLORS.mem, 75, 90),
        }));
        this._panel.memLabel = this._label('0%', 'dodopulse-panel-label');
        memBox.add_child(this._panel.memBar);
        memBox.add_child(this._panel.memLabel);

        this._panel.netLabel = this._label('', 'dodopulse-panel-label');

        this._panel.cpuBox = cpuBox;
        this._panel.memBox = memBox;
        panel.add_child(cpuBox);
        panel.add_child(memBox);
        panel.add_child(this._panel.netLabel);
        this._button.add_child(panel);

        // ── popup ──
        const item = new PopupMenu.PopupBaseMenuItem({
            reactive: false,
            can_focus: false,
            style_class: 'dodopulse-menu-item',
        });
        const root = this._vbox({style_class: 'dodopulse-popup', x_expand: true});
        item.add_child(root);
        this._button.menu.addMenuItem(item);
        this._ui = {};

        // Header
        const header = this._hbox({style_class: 'dodopulse-header'});
        header.add_child(this._label('DodoPulse', 'dodopulse-title'));
        header.add_child(this._spacer());
        this._ui.uptime = this._label('', 'dodopulse-uptime');
        header.add_child(this._ui.uptime);
        root.add_child(header);

        const sysMonitor = {apps: ['org.gnome.SystemMonitor.desktop', 'gnome-system-monitor.desktop'],
            command: ['gnome-system-monitor']};

        // CPU / Memory / GPU
        this._ui.cpu = this._metricCard(root, COLORS.cpu, t.cpu, 'cpu', sysMonitor);
        this._ui.mem = this._metricCard(root, COLORS.mem, t.memory, 'mem', {
            ...sysMonitor, command: ['gnome-system-monitor', '-r'],
        });
        this._ui.gpu = this._metricCard(root, COLORS.gpu, t.gpu, 'gpu', sysMonitor);

        // Network
        this._ui.net = this._networkCard(root);

        // Disks
        this._ui.disk = this._diskCard(root);
        this._ui.otherDisksBox = this._vbox({style: 'spacing: 6px;', x_expand: true});
        this._ui.otherDiskCards = [];
        this._ui.otherDisksKey = '';
        root.add_child(this._ui.otherDisksBox);

        // Battery
        this._ui.battery = this._batteryCard(root);

        // System
        this._ui.system = this._systemCard(root, sysMonitor);

        // Footer
        const footer = this._hbox({style_class: 'dodopulse-footer', style: 'spacing: 6px;'});
        footer.add_child(this._spacer());
        const mkButton = (label, cb) => {
            const b = new St.Button({
                label,
                style_class: 'button dodopulse-footer-button',
                can_focus: true,
            });
            b.connect('clicked', cb);
            return b;
        };
        footer.add_child(mkButton(t.systemMonitor, () => this._launch(sysMonitor)));
        footer.add_child(mkButton(t.settings, () => {
            this._button.menu.close();
            this._openPrefs();
        }));
        root.add_child(footer);

        this._menuOpenId = this._button.menu.connect('open-state-changed', (_m, open) => {
            if (open) {
                this._updatePopup();
                this._updateDisks();
            }
        });

        this._applyVisibility();
        this._updatePanel();

        const pos = this._settings.get_string('panel-position');
        Main.panel.addToStatusArea(this._uuid, this._button, pos === 'right' ? 0 : -1, pos);
    }

    _destroyIndicator() {
        if (this._button) {
            this._button.destroy();
            this._button = null;
        }
        this._panel = null;
        this._ui = null;
    }

    _rebuildIndicator() {
        this._destroyIndicator();
        this._buildIndicator();
    }

    _metricCard(parent, color, title, histKey, target) {
        const {button, box} = this._card(color, target);
        const left = this._vbox({style: 'spacing: 2px;', x_expand: true});
        const top = this._hbox({style: 'spacing: 6px;'});
        const value = this._label('0%', 'dodopulse-value', {style: `color: ${color};`});
        const badge = this._tempBadge();
        top.add_child(value);
        top.add_child(badge);
        left.add_child(top);
        const titleLabel = this._label(title, 'dodopulse-card-title');
        left.add_child(titleLabel);
        const subtitle = this._label('', 'dodopulse-subtitle', {style: 'max-width: 190px;'});
        left.add_child(subtitle);
        box.add_child(left);
        const graph = this._sparkline(100, 48, histKey, color, 100);
        graph.y_align = this._d.Clutter.ActorAlign.CENTER;
        box.add_child(graph);
        parent.add_child(button);
        return {button, value, badge, titleLabel, subtitle, graph};
    }

    _networkCard(parent) {
        const {Clutter} = this._d;
        const t = this._t;
        const {button, box} = this._card(COLORS.net, {
            command: ['gnome-control-center', 'network'],
        });
        const left = this._vbox({style: 'spacing: 2px;', x_expand: true});
        left.add_child(this._label(t.network, 'dodopulse-card-title'));
        const down = this._label('↓ 0 B/s', 'dodopulse-speed', {style: `color: ${COLORS.net};`});
        const up = this._label('↑ 0 B/s', 'dodopulse-speed', {style: `color: ${COLORS.netUp};`});
        const session = this._label('', 'dodopulse-small');
        left.add_child(down);
        left.add_child(up);
        left.add_child(session);
        box.add_child(left);

        const right = this._vbox({style: 'spacing: 1px;', y_align: Clutter.ActorAlign.CENTER});
        const local = this._label('', 'dodopulse-small', {x_align: Clutter.ActorAlign.END});
        const pub = this._label('', 'dodopulse-small', {x_align: Clutter.ActorAlign.END});
        right.add_child(local);
        right.add_child(pub);
        const graph = this._sparkline(110, 38, 'net', COLORS.net, 0);
        right.add_child(graph);
        box.add_child(right);
        parent.add_child(button);
        return {button, down, up, session, local, pub, graph};
    }

    _diskCard(parent) {
        const {Clutter} = this._d;
        const {button, box} = this._card(COLORS.disk, {
            apps: ['org.gnome.baobab.desktop', 'org.gnome.DiskUtility.desktop'],
            command: ['baobab'],
        });
        const col = this._vbox({style: 'spacing: 6px;', x_expand: true});
        const row = this._hbox({style: 'spacing: 8px;'});
        const value = this._label('0%', 'dodopulse-value-medium', {style: `color: ${COLORS.disk};`});
        row.add_child(value);
        const mid = this._vbox({y_align: Clutter.ActorAlign.CENTER});
        mid.add_child(this._label(this._t.disk, 'dodopulse-card-title'));
        const free = this._label('', 'dodopulse-subtitle');
        mid.add_child(free);
        row.add_child(mid);
        row.add_child(this._spacer());
        const right = this._vbox({y_align: Clutter.ActorAlign.CENTER});
        const mount = this._label('/', 'dodopulse-subtitle', {x_align: Clutter.ActorAlign.END});
        const model = this._label('', 'dodopulse-small', {x_align: Clutter.ActorAlign.END});
        right.add_child(mount);
        right.add_child(model);
        row.add_child(right);
        col.add_child(row);
        const bar = this._progressBar(6, () => {
            const d = this._s.disk;
            const usage = d ? d.usage : 0;
            return {fraction: usage / 100, color: levelColor(usage, COLORS.disk, 75, 90)};
        });
        col.add_child(bar);
        box.add_child(col);
        parent.add_child(button);
        return {button, value, free, mount, model, bar};
    }

    _otherDiskCard(index) {
        const {Clutter} = this._d;
        const {button, box} = this._card(COLORS.disk, {
            apps: ['org.gnome.Nautilus.desktop', 'org.gnome.baobab.desktop'],
            command: ['xdg-open', this._s.otherDisks[index]?.mount || '/'],
        }, true);
        const value = this._label('0%', 'dodopulse-value-small');
        box.add_child(value);
        const mid = this._vbox({x_expand: true, y_align: Clutter.ActorAlign.CENTER});
        const name = this._label('', 'dodopulse-subtitle', {style: 'opacity: 1; max-width: 170px;'});
        const free = this._label('', 'dodopulse-small');
        mid.add_child(name);
        mid.add_child(free);
        box.add_child(mid);
        const bar = this._progressBar(5, () => {
            const d = this._s.otherDisks[index];
            const usage = d ? d.usage : 0;
            return {fraction: usage / 100, color: levelColor(usage, COLORS.disk, 75, 90)};
        }, 60);
        bar.y_align = Clutter.ActorAlign.CENTER;
        box.add_child(bar);
        return {button, value, name, free, bar};
    }

    _batteryCard(parent) {
        const {button, box} = this._card(COLORS.batt, {
            command: ['gnome-control-center', 'power'],
        });
        const col = this._vbox({style: 'spacing: 6px;', x_expand: true});
        const row = this._hbox({style: 'spacing: 8px;'});
        const value = this._label('0%', 'dodopulse-value-medium');
        const title = this._label(this._t.battery, 'dodopulse-card-title');
        const status = this._label('', 'dodopulse-subtitle');
        row.add_child(value);
        row.add_child(title);
        row.add_child(this._spacer());
        row.add_child(status);
        col.add_child(row);
        const bar = this._progressBar(6, () => {
            const b = this._s.battery;
            return {fraction: b ? b.level / 100 : 0, color: this._batteryColor(b)};
        });
        col.add_child(bar);
        box.add_child(col);
        parent.add_child(button);
        return {button, value, title, status, bar};
    }

    _systemCard(parent, target) {
        const {button, box} = this._card(COLORS.system, target);
        const col = this._vbox({style: 'spacing: 2px;', x_expand: true});
        const row1 = this._hbox();
        row1.add_child(this._label(this._t.system, 'dodopulse-card-title'));
        row1.add_child(this._spacer());
        const procs = this._label('', 'dodopulse-subtitle');
        row1.add_child(procs);
        const row2 = this._hbox();
        const load = this._label('', 'dodopulse-card-title', {style: `color: ${COLORS.system};`});
        row2.add_child(load);
        row2.add_child(this._spacer());
        const swap = this._label('', 'dodopulse-subtitle');
        row2.add_child(swap);
        const row3 = this._hbox();
        row3.add_child(this._spacer());
        const kernel = this._label('', 'dodopulse-subtitle');
        row3.add_child(kernel);
        col.add_child(row1);
        col.add_child(row2);
        col.add_child(row3);
        box.add_child(col);
        parent.add_child(button);
        return {button, procs, load, swap, kernel};
    }

    _batteryColor(b) {
        if (!b)
            return COLORS.batt;
        if (b.status === 'Charging')
            return COLORS.charging;
        return b.level < 20 ? COLORS.danger : COLORS.batt;
    }

    // ── UI updates ──────────────────────────────────────────────────────────

    _applyVisibility() {
        if (!this._ui || !this._settings)
            return;
        const st = this._settings;
        const ui = this._ui;
        ui.cpu.button.visible = st.get_boolean('show-cpu');
        ui.mem.button.visible = st.get_boolean('show-memory');
        ui.gpu.button.visible = st.get_boolean('show-gpu');
        ui.net.button.visible = st.get_boolean('show-network');
        ui.disk.button.visible = st.get_boolean('show-disk');
        ui.otherDisksBox.visible = st.get_boolean('show-disk');
        ui.battery.button.visible = st.get_boolean('show-battery') && this._s.battery !== null;
        ui.system.button.visible = st.get_boolean('show-system');
        ui.net.pub.visible = st.get_boolean('show-public-ip');

        this._panel.cpuBox.visible = st.get_boolean('panel-show-cpu');
        this._panel.memBox.visible = st.get_boolean('panel-show-memory');
        this._panel.netLabel.visible = st.get_boolean('panel-show-network');
        // Never leave the panel button empty
        if (!this._panel.cpuBox.visible && !this._panel.memBox.visible && !this._panel.netLabel.visible)
            this._panel.cpuBox.visible = true;
    }

    _updatePanel() {
        if (!this._panel)
            return;
        const s = this._s;
        this._panel.cpuLabel.text = `${s.cpuUsage.toFixed(0)}%`;
        this._panel.memLabel.text = `${s.memUsage.toFixed(0)}%`;
        this._panel.netLabel.text = `↓${formatSpeedShort(s.netIn)} ↑${formatSpeedShort(s.netOut)}`;
        this._panel.cpuBar.queue_repaint();
        this._panel.memBar.queue_repaint();
    }

    _updatePopup() {
        if (!this._ui)
            return;
        const s = this._s;
        const t = this._t;
        const ui = this._ui;
        const showTemp = this._settings.get_boolean('show-temperature');

        ui.uptime.text = `↑ ${formatUptime(s.uptime)}`;

        // CPU
        ui.cpu.value.text = `${s.cpuUsage.toFixed(1)}%`;
        ui.cpu.value.style = `color: ${levelColor(s.cpuUsage, COLORS.cpu, 70, 90)};`;
        this._setBadge(ui.cpu.badge, showTemp ? s.cpuTemp : 0);
        const cpuTitle = [t.cpu, `${s.cpuCores} ${t.cores}`];
        if (s.cpuFreqGHz > 0)
            cpuTitle.push(`${s.cpuFreqGHz.toFixed(2)} GHz`);
        ui.cpu.titleLabel.text = cpuTitle.join(' · ');
        ui.cpu.subtitle.text = s.cpuModel || '';
        ui.cpu.graph.queue_repaint();

        // Memory
        ui.mem.value.text = `${s.memUsage.toFixed(1)}%`;
        ui.mem.value.style = `color: ${levelColor(s.memUsage, COLORS.mem, 75, 90)};`;
        ui.mem.subtitle.text = `${s.memUsedGB.toFixed(1)} / ${s.memTotalGB.toFixed(0)} GB`;
        ui.mem.graph.queue_repaint();

        // GPU
        ui.gpu.value.text = s.gpuAvailable ? `${s.gpuUsage.toFixed(0)}%` : '—';
        ui.gpu.value.style = `color: ${COLORS.gpu};`;
        this._setBadge(ui.gpu.badge, showTemp ? s.gpuTemp : 0);
        ui.gpu.titleLabel.text = s.gpuDetail ? `${t.gpu} · ${s.gpuDetail}` : t.gpu;
        ui.gpu.subtitle.text = s.gpuName || (s.gpuAvailable ? '' : t.notAvailable);
        ui.gpu.graph.queue_repaint();

        // Network
        ui.net.down.text = `↓ ${formatSpeed(s.netIn)}`;
        ui.net.up.text = `↑ ${formatSpeed(s.netOut)}`;
        ui.net.session.text = `${t.session}: ↓${formatBytes(s.netSessionIn)} ↑${formatBytes(s.netSessionOut)}`;
        ui.net.local.text = `${t.local}: ${s.localIP}`;
        ui.net.pub.text = `${t.public}: ${s.publicIP}`;
        ui.net.graph.queue_repaint();

        // Battery
        const b = s.battery;
        if (b) {
            const color = this._batteryColor(b);
            ui.battery.value.text = `${b.level}%`;
            ui.battery.value.style = `color: ${color};`;
            ui.battery.title.text = b.status === 'Charging' ? t.charging : t.battery;
            ui.battery.status.text = this._batteryStatusText(b);
            ui.battery.bar.queue_repaint();
        }
        ui.battery.button.visible = this._settings.get_boolean('show-battery') && b !== null;

        // System
        ui.system.procs.text = `${t.processes}: ${s.processCount}`;
        ui.system.load.text = `${t.load}: ${s.loadAvg.map(v => v.toFixed(2)).join('  ')}`;
        ui.system.swap.text = s.swapTotalGB > 0
            ? `${t.swap}: ${s.swapUsedGB.toFixed(1)} / ${s.swapTotalGB.toFixed(1)} GB` : '';
        ui.system.kernel.text = `${t.kernel}: ${s.kernel}`;
    }

    _setBadge(badge, temp) {
        badge.visible = temp > 0;
        if (temp > 0) {
            badge.text = `${temp.toFixed(0)}°C`;
            badge.style = `background-color: ${rgba(COLORS.temp, 0.15)}; color: ${levelColor(temp, COLORS.temp, 70, 85)};`;
        }
    }

    _batteryStatusText(b) {
        const t = this._t;
        const parts = [];
        if (b.status === 'Charging') {
            if (b.hours > 0)
                parts.push(`${formatDuration(b.hours)} ${t.untilFull}`);
        } else if (b.status === 'Full') {
            parts.push(t.fullyCharged);
        } else if (b.status === 'Discharging') {
            parts.push(b.hours > 0 ? `${formatDuration(b.hours)} ${t.left}` : t.onBattery);
        } else {
            parts.push(t.pluggedIn);
        }
        if (b.watts > 0.1)
            parts.push(`${b.watts.toFixed(1)} W`);
        return parts.join(' · ');
    }

    _updateDisks() {
        if (!this._ui)
            return;
        const s = this._s;
        const ui = this._ui;
        const t = this._t;

        if (s.disk) {
            const d = s.disk;
            ui.disk.value.text = `${d.usage.toFixed(0)}%`;
            ui.disk.value.style = `color: ${levelColor(d.usage, COLORS.disk, 75, 90)};`;
            ui.disk.free.text = `${d.freeGB.toFixed(0)} GB ${t.free} ${d.totalGB.toFixed(0)} GB`;
            ui.disk.mount.text = '/';
        }
        ui.disk.model.text = s.diskModel;
        ui.disk.model.visible = s.diskModel !== '';
        ui.disk.bar.queue_repaint();

        // Rebuild the extra disk cards only when the set of mounts changes
        const key = s.otherDisks.map(d => d.mount).join('\n');
        if (key !== ui.otherDisksKey) {
            ui.otherDisksBox.destroy_all_children();
            ui.otherDiskCards = s.otherDisks.map((_d, i) => {
                const card = this._otherDiskCard(i);
                ui.otherDisksBox.add_child(card.button);
                return card;
            });
            ui.otherDisksKey = key;
        }
        ui.otherDiskCards.forEach((card, i) => {
            const d = s.otherDisks[i];
            card.value.text = `${d.usage.toFixed(0)}%`;
            card.value.style = `color: ${levelColor(d.usage, COLORS.disk, 75, 90)};`;
            card.name.text = d.mount.split('/').pop() || d.mount;
            card.free.text = `${d.freeGB.toFixed(0)} GB ${t.free} ${d.totalGB.toFixed(0)} GB`;
            card.bar.queue_repaint();
        });
    }
};
