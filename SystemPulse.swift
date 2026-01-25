#!/usr/bin/env swift

// SystemPulse - macOS Menu Bar System Monitor
// Build: swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal

import Cocoa
import IOKit
import IOKit.ps
import Metal

// MARK: - Localization

enum Language: String, CaseIterable {
    case english = "en"
    case turkish = "tr"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case japanese = "ja"
    case chinese = "zh"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        }
    }
}

struct L10n {
    static var current: Language {
        get {
            if let code = UserDefaults.standard.string(forKey: "appLanguage"),
               let lang = Language(rawValue: code) {
                return lang
            }
            // Auto-detect from system
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            return Language(rawValue: systemLang) ?? .english
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage") }
    }

    // All translatable strings
    static var cpu: String { tr("CPU", "CPU", "CPU", "CPU", "CPU", "CPU", "CPU") }
    static var memory: String { tr("Memory", "Bellek", "Speicher", "Mémoire", "Memoria", "メモリ", "内存") }
    static var gpu: String { tr("GPU", "GPU", "GPU", "GPU", "GPU", "GPU", "GPU") }
    static var network: String { tr("Network", "Ağ", "Netzwerk", "Réseau", "Red", "ネットワーク", "网络") }
    static var disk: String { tr("Disk", "Disk", "Festplatte", "Disque", "Disco", "ディスク", "磁盘") }
    static var battery: String { tr("Battery", "Pil", "Akku", "Batterie", "Batería", "バッテリー", "电池") }
    static var charging: String { tr("Charging", "Şarj oluyor", "Lädt", "En charge", "Cargando", "充電中", "充电中") }
    static var fans: String { tr("Fans", "Fanlar", "Lüfter", "Ventilateurs", "Ventiladores", "ファン", "风扇") }
    static var system: String { tr("System", "Sistem", "System", "Système", "Sistema", "システム", "系统") }
    static var temperature: String { tr("Temperature", "Sıcaklık", "Temperatur", "Température", "Temperatura", "温度", "温度") }
    static var cores: String { tr("cores", "çekirdek", "Kerne", "cœurs", "núcleos", "コア", "核心") }
    static var processes: String { tr("Processes", "İşlemler", "Prozesse", "Processus", "Procesos", "プロセス", "进程") }
    static var uptime: String { tr("Uptime", "Çalışma süresi", "Laufzeit", "Temps de fonctionnement", "Tiempo activo", "稼働時間", "运行时间") }
    static var localIP: String { tr("Local", "Yerel", "Lokal", "Local", "Local", "ローカル", "本地") }
    static var publicIP: String { tr("Public", "Genel", "Öffentlich", "Publique", "Pública", "パブリック", "公网") }
    static var session: String { tr("Session", "Oturum", "Sitzung", "Session", "Sesión", "セッション", "会话") }
    static var freeOf: String { tr("free of", "boş /", "frei von", "libre sur", "libre de", "空き/", "可用/") }
    static var remaining: String { tr("remaining", "kaldı", "verbleibend", "restant", "restante", "残り", "剩余") }
    static var connectedToPower: String { tr("Connected to power", "Güce bağlı", "Mit Strom verbunden", "Connecté au secteur", "Conectado a la corriente", "電源に接続", "已连接电源") }
    static var notInUse: String { tr("Not in use", "Kullanılmıyor", "Nicht verwendet", "Non utilisé", "No en uso", "未使用", "未使用") }
    static var showCPUMemory: String { tr("Show CPU/Memory in menu bar", "Menü çubuğunda CPU/Bellek göster", "CPU/Speicher in Menüleiste anzeigen", "Afficher CPU/Mémoire dans la barre de menu", "Mostrar CPU/Memoria en barra de menú", "メニューバーにCPU/メモリを表示", "在菜单栏显示CPU/内存") }
    static var language: String { tr("Language", "Dil", "Sprache", "Langue", "Idioma", "言語", "语言") }
    static var about: String { tr("About SystemPulse", "SystemPulse Hakkında", "Über SystemPulse", "À propos de SystemPulse", "Acerca de SystemPulse", "SystemPulseについて", "关于SystemPulse") }
    static var quit: String { tr("Quit", "Çıkış", "Beenden", "Quitter", "Salir", "終了", "退出") }
    static var power: String { tr("Power", "Güç", "Strom", "Alimentation", "Energía", "電源", "电源") }
    static var connectedToAdapter: String { tr("Connected to power adapter", "Güç adaptörüne bağlı", "Mit Netzteil verbunden", "Connecté à l'adaptateur", "Conectado al adaptador", "電源アダプタに接続", "已连接电源适配器") }
    static var fan: String { tr("Fan", "Fan", "Lüfter", "Ventilateur", "Ventilador", "ファン", "风扇") }
    static var load: String { tr("Load", "Yük", "Last", "Charge", "Carga", "負荷", "负载") }
    static var swap: String { tr("Swap", "Takas", "Swap", "Swap", "Intercambio", "スワップ", "交换") }
    static var kernel: String { tr("Kernel", "Çekirdek", "Kernel", "Noyau", "Kernel", "カーネル", "内核") }

    private static func tr(_ en: String, _ tr: String, _ de: String, _ fr: String, _ es: String, _ ja: String, _ zh: String) -> String {
        switch current {
        case .english: return en
        case .turkish: return tr
        case .german: return de
        case .french: return fr
        case .spanish: return es
        case .japanese: return ja
        case .chinese: return zh
        }
    }
}

// MARK: - Lucide Icons (drawn programmatically)

struct LucideIcons {
    // Draw a CPU/chip icon
    static func cpu(size: CGFloat = 16, color: NSColor = .white) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            color.setStroke()
            let path = NSBezierPath()
            path.lineWidth = 1.2

            // Main chip body
            let inset: CGFloat = size * 0.2
            let body = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
            path.appendRoundedRect(body, xRadius: 2, yRadius: 2)

            // Pins on each side
            let pinLen: CGFloat = size * 0.15
            let pinGap: CGFloat = size * 0.2
            // Top pins
            for i in 0..<2 {
                let x = inset + pinGap + CGFloat(i) * pinGap * 1.5
                path.move(to: NSPoint(x: x, y: size - inset))
                path.line(to: NSPoint(x: x, y: size - inset + pinLen))
            }
            // Bottom pins
            for i in 0..<2 {
                let x = inset + pinGap + CGFloat(i) * pinGap * 1.5
                path.move(to: NSPoint(x: x, y: inset))
                path.line(to: NSPoint(x: x, y: inset - pinLen))
            }
            // Left pins
            for i in 0..<2 {
                let y = inset + pinGap + CGFloat(i) * pinGap * 1.5
                path.move(to: NSPoint(x: inset, y: y))
                path.line(to: NSPoint(x: inset - pinLen, y: y))
            }
            // Right pins
            for i in 0..<2 {
                let y = inset + pinGap + CGFloat(i) * pinGap * 1.5
                path.move(to: NSPoint(x: size - inset, y: y))
                path.line(to: NSPoint(x: size - inset + pinLen, y: y))
            }
            path.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }

    // Draw a memory/RAM icon
    static func memory(size: CGFloat = 16, color: NSColor = .white) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            color.setStroke()
            let path = NSBezierPath()
            path.lineWidth = 1.2

            // RAM stick body
            let body = NSRect(x: 2, y: size * 0.3, width: size - 4, height: size * 0.4)
            path.appendRoundedRect(body, xRadius: 1, yRadius: 1)

            // Chips on RAM
            for i in 0..<3 {
                let x = 4 + CGFloat(i) * (size - 8) / 3
                let chip = NSRect(x: x, y: size * 0.35, width: (size - 12) / 4, height: size * 0.3)
                path.appendRect(chip)
            }

            // Bottom pins
            for i in 0..<5 {
                let x = 3 + CGFloat(i) * (size - 6) / 5
                path.move(to: NSPoint(x: x, y: size * 0.3))
                path.line(to: NSPoint(x: x, y: size * 0.15))
            }
            path.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }

    // Draw a monitor icon (for menu bar)
    static func monitor(size: CGFloat = 18, color: NSColor = .white) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            color.setStroke()
            let path = NSBezierPath()
            path.lineWidth = 1.5

            // Screen
            let screen = NSRect(x: 2, y: 5, width: size - 4, height: size - 7)
            path.appendRoundedRect(screen, xRadius: 1.5, yRadius: 1.5)

            // Stand
            path.move(to: NSPoint(x: size / 2, y: 5))
            path.line(to: NSPoint(x: size / 2, y: 3))

            // Base
            path.move(to: NSPoint(x: size * 0.3, y: 3))
            path.line(to: NSPoint(x: size * 0.7, y: 3))

            path.lineCapStyle = .round
            path.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }

    // Draw a thermometer icon
    static func thermometer(size: CGFloat = 16, color: NSColor = .white) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            color.setStroke()
            let path = NSBezierPath()
            path.lineWidth = 1.2

            // Thermometer body
            let cx = size / 2
            path.move(to: NSPoint(x: cx - 2, y: size - 3))
            path.line(to: NSPoint(x: cx - 2, y: 6))
            path.appendArc(withCenter: NSPoint(x: cx, y: 4), radius: 3, startAngle: 180, endAngle: 0, clockwise: true)
            path.line(to: NSPoint(x: cx + 2, y: size - 3))
            path.appendArc(withCenter: NSPoint(x: cx, y: size - 3), radius: 2, startAngle: 0, endAngle: 180, clockwise: true)
            path.close()
            path.stroke()

            // Mercury bulb
            color.setFill()
            NSBezierPath(ovalIn: NSRect(x: cx - 2, y: 2, width: 4, height: 4)).fill()

            return true
        }
        image.isTemplate = true
        return image
    }
}

// MARK: - Settings

class Settings {
    static let shared = Settings()

    private let showDetailsKey = "showMenuBarDetails"

    var showMenuBarDetails: Bool {
        get { UserDefaults.standard.object(forKey: showDetailsKey) as? Bool ?? false }  // Default: icon only
        set { UserDefaults.standard.set(newValue, forKey: showDetailsKey) }
    }
}

// MARK: - Theme

struct Theme {
    static let bg = NSColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0)
    static let card = NSColor(red: 0.10, green: 0.10, blue: 0.13, alpha: 1.0)
    static let accent = NSColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

    static let cpu = NSColor(red: 0.35, green: 0.55, blue: 1.0, alpha: 1.0)
    static let mem = NSColor(red: 1.0, green: 0.45, blue: 0.35, alpha: 1.0)
    static let gpu = NSColor(red: 0.95, green: 0.35, blue: 0.55, alpha: 1.0)
    static let net = NSColor(red: 0.25, green: 0.9, blue: 0.55, alpha: 1.0)
    static let netUp = NSColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0)
    static let disk = NSColor(red: 0.95, green: 0.65, blue: 0.15, alpha: 1.0)
    static let batt = NSColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
    static let temp = NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
    static let fan = NSColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
    static let system = NSColor(red: 0.6, green: 0.5, blue: 0.9, alpha: 1.0)

    static let text = NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    static let text2 = NSColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
    static let text3 = NSColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 1.0)

    static let warning = NSColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1.0)
    static let danger = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
}

// MARK: - SMC

class SMCService {
    private var connection: io_connect_t = 0
    private var isConnected = false

    struct SMCKeyData {
        var key: UInt32 = 0
        var vers = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt16(0))
        var pLimitData = (UInt16(0), UInt16(0), UInt32(0), UInt32(0), UInt32(0))
        var keyInfo = (UInt32(0), UInt32(0), UInt8(0))
        var result: UInt8 = 0
        var status: UInt8 = 0
        var data8: UInt8 = 0
        var data32: UInt32 = 0
        var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    }

    init() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return }
        let result = IOServiceOpen(service, mach_task_self_, 0, &connection)
        IOObjectRelease(service)
        isConnected = (result == kIOReturnSuccess)
    }

    deinit { if isConnected { IOServiceClose(connection) } }

    func getCPUTemperature() -> Double? {
        // Try multiple keys for different Mac models
        // Apple Silicon: Tp09, Tp0T, Tp01, Tp05
        // Intel: TC0P, TC0H, TC0D, TC0E, TC0F
        let keys = ["Tp09", "Tp0T", "Tp01", "Tp05", "TC0P", "TC0H", "TC0D", "TC0E", "TC0F"]
        for key in keys {
            if let temp = readTemperature(key: key), temp > 0 && temp < 120 {
                return temp
            }
        }
        return nil
    }

    func getGPUTemperature() -> Double? {
        // Apple Silicon: Tg0f, Tg0j
        // Intel: TG0P, TG0H, TG0D
        let keys = ["Tg0f", "Tg0j", "TG0P", "TG0H", "TG0D"]
        for key in keys {
            if let temp = readTemperature(key: key), temp > 0 && temp < 120 {
                return temp
            }
        }
        return nil
    }

    func getFanSpeed(fan: Int) -> Int? { return readFanRPM(key: fan == 0 ? "F0Ac" : "F1Ac") }

    private func readTemperature(key: String) -> Double? {
        guard isConnected else { return nil }
        var inputStruct = SMCKeyData()
        var outputStruct = SMCKeyData()
        inputStruct.key = stringToUInt32(key)
        inputStruct.data8 = 5
        let inputSize = MemoryLayout<SMCKeyData>.size
        var outputSize = MemoryLayout<SMCKeyData>.size
        let result = IOConnectCallStructMethod(connection, 2, &inputStruct, inputSize, &outputStruct, &outputSize)
        guard result == kIOReturnSuccess else { return nil }
        return Double(Int16(outputStruct.bytes.0) << 8 | Int16(outputStruct.bytes.1)) / 256.0
    }

    private func readFanRPM(key: String) -> Int? {
        guard isConnected else { return nil }
        var inputStruct = SMCKeyData()
        var outputStruct = SMCKeyData()
        inputStruct.key = stringToUInt32(key)
        inputStruct.data8 = 5
        let inputSize = MemoryLayout<SMCKeyData>.size
        var outputSize = MemoryLayout<SMCKeyData>.size
        let result = IOConnectCallStructMethod(connection, 2, &inputStruct, inputSize, &outputStruct, &outputSize)
        guard result == kIOReturnSuccess else { return nil }
        return Int((UInt16(outputStruct.bytes.0) << 6) + (UInt16(outputStruct.bytes.1) >> 2))
    }

    private func stringToUInt32(_ str: String) -> UInt32 {
        var result: UInt32 = 0
        for (i, char) in str.prefix(4).enumerated() { result |= UInt32(char.asciiValue ?? 0) << (24 - i * 8) }
        return result
    }
}

// MARK: - Apple Silicon Thermal (alternative method)

class AppleSiliconThermal {
    // Try to get temperature from IOHIDService for Apple Silicon
    static func getCPUTemperature() -> Double? {
        var iterator: io_iterator_t = 0

        // Try AppleARMIODevice for M-series chips
        let matchingDict = IOServiceMatching("AppleARMIODevice")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator) == kIOReturnSuccess else { return nil }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any] {
                // Look for temperature in properties
                if let temp = props["temperature"] as? Double, temp > 0 && temp < 150 {
                    IOObjectRelease(service)
                    return temp
                }
                if let temp = props["die-temperature"] as? Double, temp > 0 && temp < 150 {
                    IOObjectRelease(service)
                    return temp
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }

        // Try thermal-sensors
        var iterator2: io_iterator_t = 0
        let matchingDict2 = IOServiceMatching("IOHIDEventService")
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict2, &iterator2) == kIOReturnSuccess else { return nil }
        defer { IOObjectRelease(iterator2) }

        service = IOIteratorNext(iterator2)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any],
               let primaryUsagePage = props["PrimaryUsagePage"] as? Int,
               primaryUsagePage == 0xFF00 { // Vendor-specific
                if let temp = props["Temperature"] as? Double, temp > 0 && temp < 150 {
                    IOObjectRelease(service)
                    return temp
                }
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator2)
        }

        return nil
    }
}

// MARK: - Metrics

class Metrics {
    var cpu: Double = 0, cpuTemp: Double = 0, cpuCores: Int = 0, cpuModel: String = ""
    var cpuHistory: [Double] = []

    var mem: Double = 0, memUsed: UInt64 = 0, memTotal: UInt64 = 0
    var memActive: UInt64 = 0, memWired: UInt64 = 0, memCompressed: UInt64 = 0
    var swapUsed: UInt64 = 0, swapTotal: UInt64 = 0
    var memHistory: [Double] = []

    var gpu: Double = 0, gpuName: String = "", gpuTemp: Double = 0
    var gpuHistory: [Double] = []
    var displayRefreshRate: Int = 0

    var netIn: Double = 0, netOut: Double = 0
    var netTotalIn: UInt64 = 0, netTotalOut: UInt64 = 0
    var localIP: String = "—", externalIP: String = "Fetching..."
    var netHistory: [Double] = []

    var diskUsed: Double = 0, diskFree: UInt64 = 0, diskTotal: UInt64 = 0, diskName: String = "Macintosh HD"

    var battLevel: Double = 100, battCharging: Bool = false, battTimeRemaining: Int = -1, hasBatt: Bool = false

    var uptime: TimeInterval = 0
    var loadAvg: (Double, Double, Double) = (0, 0, 0)
    var fanSpeed: [Int] = []
    var processCount: Int = 0, kernelVersion: String = ""

    var prevNetIn: UInt64 = 0, prevNetOut: UInt64 = 0, prevTime: Date?, prevCPUTicks: [UInt64]?
}

// MARK: - Monitor

class Monitor {
    let metrics = Metrics()
    private var metalDevice: MTLDevice?
    private let smc = SMCService()
    private var externalIPFetched = false

    init() {
        metalDevice = MTLCreateSystemDefaultDevice()
        metrics.gpuName = metalDevice?.name ?? "Unknown GPU"
        metrics.cpuCores = ProcessInfo.processInfo.processorCount

        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpuModel = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpuModel, &size, nil, 0)
        metrics.cpuModel = String(cString: cpuModel)

        var kernSize: size_t = 0
        sysctlbyname("kern.osrelease", nil, &kernSize, nil, 0)
        var kernVersion = [CChar](repeating: 0, count: kernSize)
        sysctlbyname("kern.osrelease", &kernVersion, &kernSize, nil, 0)
        metrics.kernelVersion = String(cString: kernVersion)
    }

    func update() {
        updateCPU(); updateMemory(); updateNetwork(); updateDisk(); updateBattery(); updateSystem(); updateGPU(); updateSensors()
        // Skipping external IP fetch - using fake IP for screenshots
        if !externalIPFetched { externalIPFetched = true; fetchExternalIP() }
        metrics.cpuHistory.append(metrics.cpu); if metrics.cpuHistory.count > 60 { metrics.cpuHistory.removeFirst() }
        metrics.memHistory.append(metrics.mem); if metrics.memHistory.count > 60 { metrics.memHistory.removeFirst() }
        metrics.gpuHistory.append(metrics.gpu); if metrics.gpuHistory.count > 60 { metrics.gpuHistory.removeFirst() }
        metrics.netHistory.append(metrics.netIn + metrics.netOut); if metrics.netHistory.count > 60 { metrics.netHistory.removeFirst() }
    }

    private func updateCPU() {
        var info: processor_info_array_t?
        var msgCount: mach_msg_type_number_t = 0
        var cpuCount: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &info, &msgCount)
        guard result == KERN_SUCCESS, let cpuInfo = info else { return }
        defer { vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(msgCount) * vm_size_t(MemoryLayout<integer_t>.stride)) }

        var ticks: [UInt64] = [], totalUsage: Double = 0
        for i in 0..<Int(cpuCount) {
            let off = Int(CPU_STATE_MAX) * i
            let u = UInt64(cpuInfo[off + Int(CPU_STATE_USER)]), s = UInt64(cpuInfo[off + Int(CPU_STATE_SYSTEM)])
            let idle = UInt64(cpuInfo[off + Int(CPU_STATE_IDLE)]), n = UInt64(cpuInfo[off + Int(CPU_STATE_NICE)])
            ticks.append(contentsOf: [u, s, idle, n])
            if let prev = metrics.prevCPUTicks, prev.count > off + 3 {
                let du = u - prev[off], ds = s - prev[off + 1], di = idle - prev[off + 2], dn = n - prev[off + 3]
                let total = du + ds + di + dn
                if total > 0 { totalUsage += Double(du + ds + dn) / Double(total) * 100 }
            }
        }
        if metrics.prevCPUTicks != nil { metrics.cpu = totalUsage / Double(cpuCount) }
        metrics.prevCPUTicks = ticks
    }

    private func updateMemory() {
        metrics.memTotal = ProcessInfo.processInfo.physicalMemory
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) { p in
            p.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count) }
        }
        guard result == KERN_SUCCESS else { return }
        let page = UInt64(vm_kernel_page_size)
        metrics.memActive = UInt64(stats.active_count) * page
        metrics.memWired = UInt64(stats.wire_count) * page
        metrics.memCompressed = UInt64(stats.compressor_page_count) * page
        metrics.memUsed = metrics.memActive + metrics.memWired + metrics.memCompressed
        metrics.mem = Double(metrics.memUsed) / Double(metrics.memTotal) * 100
        var swapUsage = xsw_usage(); var swapSize = MemoryLayout<xsw_usage>.size
        if sysctlbyname("vm.swapusage", &swapUsage, &swapSize, nil, 0) == 0 {
            metrics.swapUsed = UInt64(swapUsage.xsu_used); metrics.swapTotal = UInt64(swapUsage.xsu_total)
        }
    }

    private func updateNetwork() {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return }
        defer { freeifaddrs(ifaddr) }
        var totalIn: UInt64 = 0, totalOut: UInt64 = 0, cur = first
        while true {
            let iface = cur.pointee; let name = String(cString: iface.ifa_name)
            if iface.ifa_addr.pointee.sa_family == UInt8(AF_LINK), name != "lo0", let data = iface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                totalIn += UInt64(data.pointee.ifi_ibytes); totalOut += UInt64(data.pointee.ifi_obytes)
            }
            if iface.ifa_addr.pointee.sa_family == UInt8(AF_INET), name != "lo0" {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(iface.ifa_addr, socklen_t(iface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                let ip = String(cString: hostname)
                if !ip.isEmpty && !ip.hasPrefix("127.") { metrics.localIP = ip }
            }
            guard let next = iface.ifa_next else { break }; cur = next
        }
        metrics.netTotalIn = totalIn; metrics.netTotalOut = totalOut
        let now = Date()
        if let pt = metrics.prevTime {
            let dt = now.timeIntervalSince(pt)
            if dt > 0 {
                metrics.netIn = Double(totalIn > metrics.prevNetIn ? totalIn - metrics.prevNetIn : 0) / dt
                metrics.netOut = Double(totalOut > metrics.prevNetOut ? totalOut - metrics.prevNetOut : 0) / dt
            }
        }
        metrics.prevNetIn = totalIn; metrics.prevNetOut = totalOut; metrics.prevTime = now
    }

    private func fetchExternalIP() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let url = URL(string: "https://api.ipify.org"), let ip = try? String(contentsOf: url, encoding: .utf8) else {
                DispatchQueue.main.async { self?.metrics.externalIP = "—" }; return
            }
            DispatchQueue.main.async { self?.metrics.externalIP = ip }
        }
    }

    private func updateDisk() {
        let url = URL(fileURLWithPath: "/")
        guard let vals = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey, .volumeNameKey]) else { return }
        metrics.diskTotal = UInt64(vals.volumeTotalCapacity ?? 0)
        metrics.diskFree = UInt64(vals.volumeAvailableCapacityForImportantUsage ?? 0)
        metrics.diskName = vals.volumeName ?? "Macintosh HD"
        if metrics.diskTotal > 0 { metrics.diskUsed = Double(metrics.diskTotal - metrics.diskFree) / Double(metrics.diskTotal) * 100 }
    }

    private func updateBattery() {
        guard let snap = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let srcs = IOPSCopyPowerSourcesList(snap)?.takeRetainedValue() as? [CFTypeRef], !srcs.isEmpty else { metrics.hasBatt = false; return }
        for src in srcs {
            guard let info = IOPSGetPowerSourceDescription(snap, src)?.takeUnretainedValue() as? [String: Any],
                  info[kIOPSTypeKey as String] as? String == kIOPSInternalBatteryType as String else { continue }
            let cur = info[kIOPSCurrentCapacityKey as String] as? Int ?? 0, max = info[kIOPSMaxCapacityKey as String] as? Int ?? 100
            metrics.battLevel = max > 0 ? Double(cur) / Double(max) * 100 : 0
            metrics.battCharging = info[kIOPSIsChargingKey as String] as? Bool ?? false
            metrics.battTimeRemaining = info[kIOPSTimeToEmptyKey as String] as? Int ?? -1
            metrics.hasBatt = true; return
        }
    }

    private func updateSystem() {
        var bt = timeval(); var size = MemoryLayout<timeval>.size; var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        if sysctl(&mib, 2, &bt, &size, nil, 0) == 0 { metrics.uptime = Date().timeIntervalSince1970 - Double(bt.tv_sec) }
        var loadavg: [Double] = [0, 0, 0]; getloadavg(&loadavg, 3); metrics.loadAvg = (loadavg[0], loadavg[1], loadavg[2])
        var procSize: size_t = 0; sysctlbyname("kern.proc.all", nil, &procSize, nil, 0)
        metrics.processCount = procSize / MemoryLayout<kinfo_proc>.size
    }

    private func updateGPU() {
        let matchDict = IOServiceMatching("IOAccelerator"); var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchDict, &iterator) == kIOReturnSuccess else { return }
        defer { IOObjectRelease(iterator) }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == kIOReturnSuccess,
               let props = properties?.takeRetainedValue() as? [String: Any],
               let perfStats = props["PerformanceStatistics"] as? [String: Any],
               let gpuUtil = perfStats["Device Utilization %"] as? Int { metrics.gpu = Double(gpuUtil) }
            IOObjectRelease(service); service = IOIteratorNext(iterator)
        }

        // Get display refresh rate
        if let mode = CGDisplayCopyDisplayMode(CGMainDisplayID()) {
            let refreshRate = mode.refreshRate
            // ProMotion displays report 0 for variable refresh - check nominal rate
            if refreshRate > 0 {
                metrics.displayRefreshRate = Int(refreshRate)
            } else {
                // For ProMotion displays, assume max refresh rate (typically 120Hz)
                metrics.displayRefreshRate = 120
            }
        }
    }

    private func updateSensors() {
        // Try SMC first (Intel Macs and some Apple Silicon)
        if let temp = smc.getCPUTemperature() {
            metrics.cpuTemp = temp
        } else if let temp = AppleSiliconThermal.getCPUTemperature() {
            // Fallback to Apple Silicon thermal reading
            metrics.cpuTemp = temp
        }

        if let temp = smc.getGPUTemperature() {
            metrics.gpuTemp = temp
        }

        metrics.fanSpeed = []
        for i in 0..<2 { if let rpm = smc.getFanSpeed(fan: i), rpm > 0 { metrics.fanSpeed.append(rpm) } }
    }
}

// MARK: - Card Types for click handling

enum CardType: String {
    case cpu, memory, gpu, network, disk, battery, fans, system

    var systemApp: String {
        switch self {
        case .cpu, .memory, .system: return "Activity Monitor"
        case .gpu: return "System Information"
        case .network: return "Network"  // System Preferences pane
        case .disk: return "Disk Utility"
        case .battery: return "Battery"  // System Preferences pane
        case .fans: return "System Information"
        }
    }

    func open() {
        switch self {
        case .cpu, .memory, .system:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app"))
        case .gpu, .fans:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/System Information.app"))
        case .network:
            // macOS Sonoma+ network settings - try multiple URL schemes
            let urls = [
                "x-apple.systempreferences:com.apple.wifi-settings-extension",
                "x-apple.systempreferences:com.apple.Network-Settings.extension",
                "x-apple.systempreferences:com.apple.preference.network"
            ]
            for urlString in urls {
                if let url = URL(string: urlString), NSWorkspace.shared.open(url) { break }
            }
        case .disk:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Disk Utility.app"))
        case .battery:
            // macOS Sonoma+ battery settings
            if let url = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

// MARK: - Content View

class ContentView: NSView {
    var metrics: Metrics?
    let pad: CGFloat = 16
    let gap: CGFloat = 8
    var cardRects: [CardType: NSRect] = [:]

    override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        for (card, rect) in cardRects {
            if rect.contains(loc) {
                card.open()
                return
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let m = metrics else { return }

        // Clear card rects
        cardRects.removeAll()

        // Fill entire background
        Theme.bg.setFill()
        NSRect(x: 0, y: 0, width: frame.width, height: frame.height).fill()

        let w = frame.width - pad * 2
        var y = frame.height - pad

        // HEADER
        y -= 24
        let shadow = NSShadow()
        shadow.shadowColor = Theme.accent.withAlphaComponent(0.5)
        shadow.shadowBlurRadius = 8
        "SystemPulse".draw(at: NSPoint(x: pad, y: y), withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: Theme.text, .shadow: shadow])
        Theme.accent.withAlphaComponent(0.2).setFill()
        NSBezierPath(roundedRect: NSRect(x: pad + 102, y: y + 2, width: 34, height: 16), xRadius: 4, yRadius: 4).fill()
        "PRO".draw(at: NSPoint(x: pad + 108, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: Theme.accent])
        let up = formatUptime(m.uptime)
        up.draw(at: NSPoint(x: frame.width - pad - up.size(withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)]).width, y: y + 2), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: Theme.text2])
        y -= gap

        // CPU - 88px
        let cpuH: CGFloat = 88
        y -= cpuH
        let cpuRect = NSRect(x: pad, y: y, width: w, height: cpuH)
        cardRects[.cpu] = cpuRect
        drawCardGlow(x: pad, y: y, w: w, h: cpuH, color: Theme.cpu, intensity: m.cpu / 100)
        let cpuColor = m.cpu > 90 ? Theme.danger : (m.cpu > 70 ? Theme.warning : Theme.cpu)
        String(format: "%.1f%%", m.cpu).draw(at: NSPoint(x: pad + 14, y: y + cpuH - 36), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .bold), .foregroundColor: cpuColor])
        L10n.cpu.draw(at: NSPoint(x: pad + 14, y: y + cpuH - 52), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        m.cpuModel.replacingOccurrences(of: "Apple ", with: "").draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        "\(m.cpuCores) \(L10n.cores)".draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: Theme.text3])
        if m.cpuTemp > 0 {
            let tc = m.cpuTemp > 85 ? Theme.danger : (m.cpuTemp > 70 ? Theme.warning : Theme.temp)
            tc.withAlphaComponent(0.15).setFill()
            NSBezierPath(roundedRect: NSRect(x: pad + 115, y: y + cpuH - 36, width: 52, height: 24), xRadius: 6, yRadius: 6).fill()
            String(format: "%.0f°C", m.cpuTemp).draw(at: NSPoint(x: pad + 122, y: y + cpuH - 34), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold), .foregroundColor: tc])
        }
        drawSparkline(m.cpuHistory, x: pad + w - 115, y: y + 6, w: 105, h: cpuH - 12, color: Theme.cpu)
        y -= gap

        // MEMORY - 88px
        let memH: CGFloat = 88
        y -= memH
        let memRect = NSRect(x: pad, y: y, width: w, height: memH)
        cardRects[.memory] = memRect
        drawCardGlow(x: pad, y: y, w: w, h: memH, color: Theme.mem, intensity: m.mem / 100)
        let memColor = m.mem > 90 ? Theme.danger : (m.mem > 75 ? Theme.warning : Theme.mem)
        String(format: "%.1f%%", m.mem).draw(at: NSPoint(x: pad + 14, y: y + memH - 36), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .bold), .foregroundColor: memColor])
        L10n.memory.draw(at: NSPoint(x: pad + 14, y: y + memH - 52), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        String(format: "%.1f / %.0f GB", Double(m.memUsed)/(1024*1024*1024), Double(m.memTotal)/(1024*1024*1024)).draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        String(format: "Act: %.1fG  Wire: %.1fG  Comp: %.1fG", Double(m.memActive)/(1024*1024*1024), Double(m.memWired)/(1024*1024*1024), Double(m.memCompressed)/(1024*1024*1024)).draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 9, weight: .regular), .foregroundColor: Theme.text3])
        drawSparkline(m.memHistory, x: pad + w - 115, y: y + 6, w: 105, h: memH - 12, color: Theme.mem)
        y -= gap

        // GPU - 88px (with graph)
        let gpuH: CGFloat = 88
        y -= gpuH
        let gpuRect = NSRect(x: pad, y: y, width: w, height: gpuH)
        cardRects[.gpu] = gpuRect
        drawCardGlow(x: pad, y: y, w: w, h: gpuH, color: Theme.gpu, intensity: m.gpu / 100)
        String(format: "%.0f%%", m.gpu).draw(at: NSPoint(x: pad + 14, y: y + gpuH - 36), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .bold), .foregroundColor: Theme.gpu])
        L10n.gpu.draw(at: NSPoint(x: pad + 14, y: y + gpuH - 52), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        m.gpuName.replacingOccurrences(of: "Apple ", with: "").draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        // Display refresh rate
        if m.displayRefreshRate > 0 {
            "\(m.displayRefreshRate) Hz".draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        }
        if m.gpuTemp > 0 {
            let gt = m.gpuTemp > 85 ? Theme.danger : (m.gpuTemp > 70 ? Theme.warning : Theme.temp)
            gt.withAlphaComponent(0.15).setFill()
            NSBezierPath(roundedRect: NSRect(x: pad + 95, y: y + gpuH - 36, width: 52, height: 24), xRadius: 6, yRadius: 6).fill()
            String(format: "%.0f°C", m.gpuTemp).draw(at: NSPoint(x: pad + 102, y: y + gpuH - 34), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold), .foregroundColor: gt])
        }
        drawSparkline(m.gpuHistory, x: pad + w - 115, y: y + 6, w: 105, h: gpuH - 12, color: Theme.gpu)
        y -= gap

        // NETWORK - 100px
        let netH: CGFloat = 100
        y -= netH
        let netRect = NSRect(x: pad, y: y, width: w, height: netH)
        cardRects[.network] = netRect
        drawCardGlow(x: pad, y: y, w: w, h: netH, color: Theme.net, intensity: min((m.netIn + m.netOut) / 10000000, 1.0))
        L10n.network.draw(at: NSPoint(x: pad + 14, y: y + netH - 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        "↓".draw(at: NSPoint(x: pad + 14, y: y + 56), withAttributes: [.font: NSFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: Theme.net])
        formatSpeed(m.netIn).draw(at: NSPoint(x: pad + 34, y: y + 58), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), .foregroundColor: Theme.net])
        "↑".draw(at: NSPoint(x: pad + 14, y: y + 32), withAttributes: [.font: NSFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: Theme.netUp])
        formatSpeed(m.netOut).draw(at: NSPoint(x: pad + 34, y: y + 34), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), .foregroundColor: Theme.netUp])
        "\(L10n.session): ↓\(formatBytes(m.netTotalIn))  ↑\(formatBytes(m.netTotalOut))".draw(at: NSPoint(x: pad + 14, y: y + 8), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: Theme.text3])
        // IPs on right - positioned above the graph
        "\(L10n.localIP):".draw(at: NSPoint(x: pad + 175, y: y + netH - 30), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        m.localIP.draw(at: NSPoint(x: pad + 215, y: y + netH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: Theme.text2])
        "\(L10n.publicIP):".draw(at: NSPoint(x: pad + 175, y: y + netH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: Theme.text3])
        m.externalIP.draw(at: NSPoint(x: pad + 215, y: y + netH - 48), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular), .foregroundColor: Theme.text2])
        // Graph at bottom right
        drawSparkline(m.netHistory, x: pad + w - 115, y: y + 6, w: 105, h: 40, color: Theme.net)
        y -= gap

        // DISK - 80px
        let diskH: CGFloat = 80
        y -= diskH
        let diskRect = NSRect(x: pad, y: y, width: w, height: diskH)
        cardRects[.disk] = diskRect
        drawCard(x: pad, y: y, w: w, h: diskH)
        let diskColor = m.diskUsed > 90 ? Theme.danger : (m.diskUsed > 75 ? Theme.warning : Theme.disk)
        // Percentage at top
        String(format: "%.0f%%", m.diskUsed).draw(at: NSPoint(x: pad + 14, y: y + diskH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .bold), .foregroundColor: diskColor])
        // "Disk" label below percentage
        L10n.disk.draw(at: NSPoint(x: pad + 14, y: y + diskH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        // GB info
        String(format: "%.0f GB \(L10n.freeOf) %.0f GB", Double(m.diskFree)/(1024*1024*1024), Double(m.diskTotal)/(1024*1024*1024)).draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        // Disk name at bottom
        m.diskName.draw(at: NSPoint(x: pad + 14, y: y + 2), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: Theme.text3])
        // Progress bar on right side
        drawProgressBar(value: m.diskUsed / 100, x: pad + 185, y: y + 14, w: w - 200, h: 10, color: diskColor)
        y -= gap

        // BATTERY - 72px
        let battH: CGFloat = 72
        y -= battH
        let battRect = NSRect(x: pad, y: y, width: w, height: battH)
        cardRects[.battery] = battRect
        drawCard(x: pad, y: y, w: w, h: battH)
        if m.hasBatt {
            let battColor = m.battCharging ? Theme.accent : (m.battLevel < 20 ? Theme.danger : (m.battLevel < 40 ? Theme.warning : Theme.batt))
            // Percentage at top
            "\(Int(m.battLevel))%".draw(at: NSPoint(x: pad + 14, y: y + battH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .bold), .foregroundColor: battColor])
            // Label below percentage
            (m.battCharging ? L10n.charging : L10n.battery).draw(at: NSPoint(x: pad + 14, y: y + battH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            // Time remaining or status
            if m.battTimeRemaining > 0 && !m.battCharging {
                let h = m.battTimeRemaining / 60, mn = m.battTimeRemaining % 60
                (h > 0 ? "\(h)h \(mn)m \(L10n.remaining)" : "\(mn)m \(L10n.remaining)").draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
            } else if m.battCharging {
                L10n.connectedToPower.draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.accent])
            }
            drawProgressBar(value: m.battLevel / 100, x: pad + 14, y: y + 4, w: w - 30, h: 10, color: battColor)
        } else {
            "AC".draw(at: NSPoint(x: pad + 14, y: y + battH - 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 22, weight: .bold), .foregroundColor: Theme.batt])
            L10n.power.draw(at: NSPoint(x: pad + 14, y: y + battH - 48), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            L10n.connectedToAdapter.draw(at: NSPoint(x: pad + 14, y: y + 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.batt])
        }
        y -= gap

        // FANS - 48px (if available)
        if !m.fanSpeed.isEmpty {
            let fanH: CGFloat = 48
            y -= fanH
            let fanRect = NSRect(x: pad, y: y, width: w, height: fanH)
            cardRects[.fans] = fanRect
            drawCard(x: pad, y: y, w: w, h: fanH)
            L10n.fans.draw(at: NSPoint(x: pad + 14, y: y + fanH - 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
            for (i, rpm) in m.fanSpeed.enumerated() {
                "\(L10n.fan) \(i + 1): \(rpm) RPM".draw(at: NSPoint(x: pad + 14 + CGFloat(i) * 150, y: y + 8), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold), .foregroundColor: Theme.fan])
            }
            y -= gap
        }

        // SYSTEM - 68px
        let sysH: CGFloat = 68
        y -= sysH
        let sysRect = NSRect(x: pad, y: y, width: w, height: sysH)
        cardRects[.system] = sysRect
        drawCard(x: pad, y: y, w: w, h: sysH)
        L10n.system.draw(at: NSPoint(x: pad + 14, y: y + sysH - 16), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: Theme.text2])
        String(format: "\(L10n.load): %.2f  %.2f  %.2f", m.loadAvg.0, m.loadAvg.1, m.loadAvg.2).draw(at: NSPoint(x: pad + 14, y: y + 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium), .foregroundColor: Theme.system])
        "\(L10n.processes): \(m.processCount)".draw(at: NSPoint(x: pad + 220, y: y + 30), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium), .foregroundColor: Theme.text2])
        if m.swapUsed > 0 {
            String(format: "\(L10n.swap): %.1f / %.1f GB", Double(m.swapUsed)/(1024*1024*1024), Double(m.swapTotal)/(1024*1024*1024)).draw(at: NSPoint(x: pad + 14, y: y + 10), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text2])
        } else {
            "\(L10n.swap): \(L10n.notInUse)".draw(at: NSPoint(x: pad + 14, y: y + 10), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text3])
        }
        "\(L10n.kernel): \(m.kernelVersion)".draw(at: NSPoint(x: pad + 220, y: y + 10), withAttributes: [.font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium), .foregroundColor: Theme.text3])
    }

    func drawCard(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        Theme.card.setFill()
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 12, yRadius: 12).fill()
        NSColor(white: 0.18, alpha: 0.5).setStroke()
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 12, yRadius: 12).stroke()
    }

    func drawHoverArrow(in rect: NSRect) {
        // Draw a subtle highlight overlay
        Theme.accent.withAlphaComponent(0.08).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12).fill()

        // Draw arrow on the right side
        let arrowX = rect.maxX - 24
        let arrowY = rect.midY

        // Arrow background circle
        Theme.accent.withAlphaComponent(0.2).setFill()
        NSBezierPath(ovalIn: NSRect(x: arrowX - 10, y: arrowY - 10, width: 20, height: 20)).fill()

        // Arrow chevron ">"
        let arrow = NSBezierPath()
        arrow.move(to: NSPoint(x: arrowX - 3, y: arrowY + 5))
        arrow.line(to: NSPoint(x: arrowX + 3, y: arrowY))
        arrow.line(to: NSPoint(x: arrowX - 3, y: arrowY - 5))
        Theme.accent.setStroke()
        arrow.lineWidth = 2
        arrow.lineCapStyle = .round
        arrow.lineJoinStyle = .round
        arrow.stroke()
    }

    func drawCardGlow(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor, intensity: Double) {
        if intensity > 0.5 {
            color.withAlphaComponent((intensity - 0.5) * 0.25).setFill()
            NSBezierPath(roundedRect: NSRect(x: x - 2, y: y - 2, width: w + 4, height: h + 4), xRadius: 14, yRadius: 14).fill()
        }
        drawCard(x: x, y: y, w: w, h: h)
    }

    func drawProgressBar(value: Double, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor) {
        NSColor(white: 0.15, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: h/2, yRadius: h/2).fill()
        let fillW = w * CGFloat(min(max(value, 0), 1))
        if fillW > 0 { color.setFill(); NSBezierPath(roundedRect: NSRect(x: x, y: y, width: fillW, height: h), xRadius: h/2, yRadius: h/2).fill() }
    }

    func drawSparkline(_ values: [Double], x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor) {
        // Transparent background - just a subtle border
        color.withAlphaComponent(0.1).setFill()
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 6, yRadius: 6).fill()
        guard values.count >= 2 else { return }
        let maxV = max(values.max() ?? 100, 1)
        var pts: [NSPoint] = []
        for (i, v) in values.enumerated() {
            pts.append(NSPoint(x: x + 4 + CGFloat(i) / CGFloat(values.count - 1) * (w - 8), y: y + 4 + min(v / maxV, 1) * (h - 8)))
        }
        let fill = NSBezierPath(); fill.move(to: NSPoint(x: pts[0].x, y: y + 4)); pts.forEach { fill.line(to: $0) }; fill.line(to: NSPoint(x: pts.last!.x, y: y + 4)); fill.close()
        NSGradient(colors: [color.withAlphaComponent(0.4), color.withAlphaComponent(0.05)])?.draw(in: fill, angle: 90)
        let line = NSBezierPath(); line.move(to: pts[0]); pts.dropFirst().forEach { line.line(to: $0) }
        color.withAlphaComponent(0.4).setStroke(); line.lineWidth = 2.5; line.stroke()
        color.setStroke(); line.lineWidth = 1.5; line.stroke()
        if let last = pts.last { color.setFill(); NSBezierPath(ovalIn: NSRect(x: last.x - 3, y: last.y - 3, width: 6, height: 6)).fill() }
    }

    func formatSpeed(_ bps: Double) -> String {
        if bps < 1024 { return String(format: "%.0f B/s", bps) }
        if bps < 1024 * 1024 { return String(format: "%.1f KB/s", bps / 1024) }
        return String(format: "%.2f MB/s", bps / (1024 * 1024))
    }

    func formatBytes(_ bytes: UInt64) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        if bytes < 1024 * 1024 { return String(format: "%.1f KB", Double(bytes) / 1024) }
        if bytes < 1024 * 1024 * 1024 { return String(format: "%.1f MB", Double(bytes) / (1024 * 1024)) }
        return String(format: "%.2f GB", Double(bytes) / (1024 * 1024 * 1024))
    }

    func formatUptime(_ s: TimeInterval) -> String {
        let d = Int(s) / 86400, h = (Int(s) % 86400) / 3600, m = (Int(s) % 3600) / 60
        if d > 0 { return "↑ \(d)d \(h)h \(m)m" }
        if h > 0 { return "↑ \(h)h \(m)m" }
        return "↑ \(m)m"
    }
}

// MARK: - Borderless Panel

class BorderlessPanel: NSPanel {
    override var canBecomeKey: Bool { true }

    init(contentRect: NSRect) {
        super.init(contentRect: contentRect,
                   styleMask: [.nonactivatingPanel, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)

        isFloatingPanel = true
        level = .popUpMenu
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // Round corners
        if let contentView = contentView {
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 12
            contentView.layer?.masksToBounds = true
            contentView.layer?.backgroundColor = Theme.bg.cgColor
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var panel: BorderlessPanel!
    var contentView: ContentView!
    var monitor = Monitor()
    var timer: Timer?
    var menu: NSMenu!
    var eventMonitor: Any?
    var showDetailsMenuItem: NSMenuItem!
    var cpuMenuItem: NSMenuItem!
    var memMenuItem: NSMenuItem!
    var tempMenuItem: NSMenuItem!

    func createMenuBarIcon() -> NSImage {
        // Create a monitor/display icon (similar to Lucide's "monitor" icon)
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()

            // Monitor screen (rounded rectangle)
            let screenRect = NSRect(x: 2, y: 5, width: 14, height: 10)
            let screen = NSBezierPath(roundedRect: screenRect, xRadius: 1.5, yRadius: 1.5)
            screen.lineWidth = 1.5
            screen.stroke()

            // Stand neck
            let neck = NSBezierPath()
            neck.move(to: NSPoint(x: 9, y: 5))
            neck.line(to: NSPoint(x: 9, y: 3))
            neck.lineWidth = 1.5
            neck.stroke()

            // Stand base
            let base = NSBezierPath()
            base.move(to: NSPoint(x: 5, y: 3))
            base.line(to: NSPoint(x: 13, y: 3))
            base.lineWidth = 1.5
            base.lineCapStyle = .round
            base.stroke()

            return true
        }
        image.isTemplate = true  // Adapts to menu bar color
        return image
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = statusItem.button {
            btn.image = createMenuBarIcon()
            btn.imagePosition = .imageLeading
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
            btn.action = #selector(handleClick)
            btn.target = self
        }

        let hasFans = !monitor.metrics.fanSpeed.isEmpty
        let height: CGFloat = hasFans ? 752 : 696

        panel = BorderlessPanel(contentRect: NSRect(x: 0, y: 0, width: 380, height: height))

        contentView = ContentView(frame: NSRect(x: 0, y: 0, width: 380, height: height))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = Theme.bg.cgColor
        contentView.layer?.cornerRadius = 12
        panel.contentView?.addSubview(contentView)

        setupMenu()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.update() }
        update()
    }

    func setupMenu() {
        menu = NSMenu()

        // Header with current stats
        let headerItem = NSMenuItem(title: "SystemPulse Pro", action: nil, keyEquivalent: "")
        menu.addItem(headerItem)
        menu.addItem(NSMenuItem.separator())

        // Current readings (non-clickable)
        cpuMenuItem = NSMenuItem(title: "\(L10n.cpu): ---%", action: nil, keyEquivalent: "")
        memMenuItem = NSMenuItem(title: "\(L10n.memory): ---%", action: nil, keyEquivalent: "")
        tempMenuItem = NSMenuItem(title: "\(L10n.temperature): ---", action: nil, keyEquivalent: "")
        menu.addItem(cpuMenuItem)
        menu.addItem(memMenuItem)
        menu.addItem(tempMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Settings toggle for menu bar display
        showDetailsMenuItem = NSMenuItem(title: L10n.showCPUMemory, action: #selector(toggleMenuBarDetails), keyEquivalent: "")
        showDetailsMenuItem.target = self
        showDetailsMenuItem.state = Settings.shared.showMenuBarDetails ? .on : .off
        menu.addItem(showDetailsMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Language submenu
        let languageItem = NSMenuItem(title: L10n.language, action: nil, keyEquivalent: "")
        let languageMenu = NSMenu()
        for lang in Language.allCases {
            let item = NSMenuItem(title: lang.displayName, action: #selector(changeLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = lang
            if lang == L10n.current { item.state = .on }
            languageMenu.addItem(item)
        }
        languageItem.submenu = languageMenu
        menu.addItem(languageItem)

        menu.addItem(NSMenuItem.separator())

        // About
        let aboutItem = NSMenuItem(title: L10n.about, action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L10n.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    @objc func changeLanguage(_ sender: NSMenuItem) {
        guard let lang = sender.representedObject as? Language else { return }
        L10n.current = lang
        // Rebuild menu with new language
        setupMenu()
        // Refresh the panel
        contentView.needsDisplay = true
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "SystemPulse Pro"
        alert.informativeText = "A lightweight macOS menu bar app for real-time system monitoring.\n\n© 2026 Dr. Gorkem Cetin\n\nhttps://github.com/bluewave-labs/systempulse"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Repository")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://github.com/bluewave-labs/systempulse") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @objc func toggleMenuBarDetails() {
        Settings.shared.showMenuBarDetails.toggle()
        showDetailsMenuItem.state = Settings.shared.showMenuBarDetails ? .on : .off
        updateMenuBarDisplay()
    }

    func updateMenuBarDisplay() {
        let m = monitor.metrics

        // Update menu bar text display
        if Settings.shared.showMenuBarDetails {
            var menuText = " C:\(Int(m.cpu))% M:\(Int(m.mem))%"
            if m.cpuTemp > 0 { menuText += " \(Int(m.cpuTemp))°" }
            statusItem.button?.title = menuText
        } else {
            statusItem.button?.title = ""
        }

        // Update menu items
        cpuMenuItem?.title = String(format: "CPU: %.1f%%", m.cpu)
        memMenuItem?.title = String(format: "Memory: %.1f%%", m.mem)
        if m.cpuTemp > 0 {
            tempMenuItem?.title = String(format: "CPU Temp: %.0f°C", m.cpuTemp)
            if m.gpuTemp > 0 {
                tempMenuItem?.title = String(format: "Temp: CPU %.0f°C / GPU %.0f°C", m.cpuTemp, m.gpuTemp)
            }
        } else {
            tempMenuItem?.title = "Temperature: N/A"
        }
    }

    func update() {
        monitor.update()
        updateMenuBarDisplay()

        if panel.isVisible {
            let hasFans = !monitor.metrics.fanSpeed.isEmpty
            let newHeight: CGFloat = hasFans ? 752 : 696
            if panel.frame.height != newHeight {
                var frame = panel.frame
                frame.size.height = newHeight
                panel.setFrame(frame, display: true)
                contentView.frame = NSRect(x: 0, y: 0, width: 380, height: newHeight)
            }
            contentView.metrics = monitor.metrics
            contentView.needsDisplay = true
        }
    }

    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            // Close panel first if it's open
            if panel.isVisible {
                panel.orderOut(nil)
                if let monitor = eventMonitor {
                    NSEvent.removeMonitor(monitor)
                    eventMonitor = nil
                }
            }
            statusItem.menu = menu; statusItem.button?.performClick(nil); statusItem.menu = nil
        } else { togglePanel() }
    }

    func togglePanel() {
        if panel.isVisible {
            panel.orderOut(nil)
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
        } else if let btn = statusItem.button, let btnWindow = btn.window {
            let hasFans = !monitor.metrics.fanSpeed.isEmpty
            let height: CGFloat = hasFans ? 752 : 696

            // Position panel below the menu bar button
            let btnRect = btn.convert(btn.bounds, to: nil)
            let screenRect = btnWindow.convertToScreen(btnRect)
            let x = screenRect.midX - 190  // Center the 380px panel
            let y = screenRect.minY - height - 4  // 4px gap below button

            panel.setFrame(NSRect(x: x, y: y, width: 380, height: height), display: true)
            contentView.frame = NSRect(x: 0, y: 0, width: 380, height: height)
            contentView.metrics = monitor.metrics
            contentView.needsDisplay = true
            panel.orderFront(nil)

            // Close when clicking outside
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.panel.orderOut(nil)
                if let monitor = self?.eventMonitor {
                    NSEvent.removeMonitor(monitor)
                    self?.eventMonitor = nil
                }
            }
        }
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
