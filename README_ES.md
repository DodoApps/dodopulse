# SystemPulse

🌍 **Disponible en 7 idiomas:** 🇺🇸 [English](README.md) | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 [Français](README_FR.md) | 🇪🇸 Español | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

Una aplicación ligera y nativa para la barra de menús de macOS que muestra métricas del sistema en tiempo real con hermosos mini gráficos.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Licencia](https://img.shields.io/badge/Licencia-MIT-green)

## Características

- **Monitoreo de CPU** - Porcentaje de uso, temperatura, frecuencia (Intel), seguimiento por núcleo con gráfico histórico
- **Monitoreo de memoria** - Memoria usada/libre, desglose activa/wired/comprimida
- **Monitoreo de GPU** - Porcentaje de utilización, temperatura, tasa de actualización de pantalla (Hz)
- **Monitoreo de red** - Velocidades de descarga/subida, IP local y pública, totales de sesión
- **Monitoreo de disco** - Porcentaje de uso, espacio libre, salud del SSD (si está disponible)
- **Monitoreo de batería** - Nivel de carga, estado de carga, tiempo restante, consumo de energía
- **Monitoreo de ventiladores** - RPM para cada ventilador (si está disponible)
- **Info del sistema** - Carga promedio, cantidad de procesos, uso de swap, versión del kernel, tiempo de actividad, brillo de pantalla
- **Soporte multiidioma** - Elige tu idioma desde el menú (7 idiomas disponibles)

### Características interactivas

- **Haz clic** en cualquier tarjeta para abrir la aplicación del sistema correspondiente (Monitor de Actividad, Utilidad de Discos, Configuración del Sistema, etc.)
- **Clic derecho** en el icono de la barra de menús para un menú rápido con configuración y selección de idioma

## Requisitos

- macOS 12.0 (Monterey) o posterior
- Mac con Apple Silicon o Intel

## Instalación

> **Sobre la notarización:** SystemPulse actualmente no está notarizado por Apple. La notarización es el proceso de seguridad de Apple que escanea las aplicaciones en busca de malware antes de su distribución. Sin ella, macOS muestra una advertencia en el primer inicio. Es seguro omitir esto para aplicaciones de código abierto como SystemPulse donde puedes inspeccionar el código tú mismo. La notarización está planificada para una versión futura.

### Opción 1: Homebrew (recomendado)

```bash
brew tap bluewave-labs/systempulse
brew install --cask systempulse
```

En el primer inicio, haz clic derecho en la app → Abrir → confirmar. O ejecuta: `xattr -cr /Applications/SystemPulse.app`

### Opción 2: Descargar DMG

1. Descarga el último DMG desde [Releases](https://github.com/bluewave-labs/systempulse/releases)
2. Abre el DMG y arrastra SystemPulse a Aplicaciones
3. En el primer inicio, clic derecho → Abrir → confirmar (ver nota sobre notarización arriba)

### Opción 3: Compilar desde el código fuente

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. Compilar la aplicación:
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Ejecutar:
   ```bash
   ./SystemPulse
   ```

### Opción 4: Crear un paquete de aplicación (opcional)

Si quieres que SystemPulse aparezca como una aplicación macOS propiamente dicha:

1. Crear la estructura de la aplicación:
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. Crear `SystemPulse.app/Contents/Info.plist`:
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

3. Mover a Aplicaciones (opcional):
   ```bash
   mv SystemPulse.app /Applications/
   ```

### Opción 5: Ejecutar con Automator

Este método permite que SystemPulse se ejecute independientemente de la Terminal, por lo que sigue funcionando incluso después de cerrar la Terminal.

1. Primero compila SystemPulse (ver Opción 1 arriba)

2. Abre **Automator** (búscalo en Spotlight)

3. Haz clic en **Nuevo documento** y selecciona **Aplicación**

4. En la barra de búsqueda, escribe "Ejecutar script de shell" y arrástralo al área de flujo de trabajo

5. Reemplaza el texto predeterminado con la ruta completa a tu binario de SystemPulse:
   ```bash
   /ruta/a/systempulse/SystemPulse
   ```
   Por ejemplo, si clonaste en tu carpeta personal:
   ```bash
   ~/systempulse/SystemPulse
   ```

6. Ve a **Archivo** > **Guardar** y guárdalo como "SystemPulse" en tu carpeta de Aplicaciones

7. Haz doble clic en la aplicación de Automator guardada para ejecutar SystemPulse

**Consejo:** Puedes agregar SystemPulse a tus Ítems de inicio de sesión para iniciarlo automáticamente al arrancar:
1. Abre **Configuración del Sistema** > **General** > **Ítems de inicio de sesión**
2. Haz clic en **+** y selecciona tu aplicación de Automator SystemPulse

## Uso

Una vez ejecutándose, SystemPulse aparece en tu barra de menús mostrando el uso de CPU y memoria.

- **Clic izquierdo** en el elemento de la barra de menús para abrir el panel detallado
- **Clic derecho** para un menú rápido con configuración, selección de idioma y opción de Salir
- **Haz clic** en una tarjeta para abrir la aplicación del sistema relacionada

### Cambiar idioma

1. Haz clic derecho en el icono de SystemPulse en la barra de menús
2. Selecciona **Idioma** del menú
3. Elige tu idioma preferido del submenú

## Detalles técnicos

SystemPulse utiliza APIs nativas de macOS para métricas precisas:

- **CPU**: API Mach `host_processor_info()`
- **Memoria**: API Mach `host_statistics64()`
- **GPU**: Servicio IOKit `IOAccelerator`
- **Red**: `getifaddrs()` para estadísticas de interfaz
- **Batería**: `IOPSCopyPowerSourcesInfo()` de IOKit
- **Temperatura/Ventiladores**: SMC (System Management Controller) vía IOKit

## Contribuir

¡Las contribuciones son bienvenidas! No dudes en enviar un pull request.

### Agregar traducciones

SystemPulse permite agregar nuevos idiomas fácilmente. Para agregar un nuevo idioma:

1. Agrega un nuevo caso al enum `Language`
2. Agrega traducciones para todas las cadenas en el struct `L10n`
3. Envía un pull request

## Licencia

Licencia MIT - ver [LICENSE](LICENSE) para más detalles.

## Agradecimientos

Desarrollado con Swift y AppKit para rendimiento nativo de macOS.
