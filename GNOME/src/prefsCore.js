// DodoPulse GNOME Shell extension - shared preferences window
//
// Shared by the legacy (GNOME 43/44) and ESM (GNOME 45+) flavours, see core.js.
// Only widgets available in libadwaita 1.2 (GNOME 43) are used.

/* exported fillDodoPulsePreferences */

const PREFS_STRINGS = {
    en: {
        general: 'General', interval: 'Update interval', intervalSub: 'How often metrics are refreshed (milliseconds)',
        position: 'Top bar position', positionSub: 'Where the indicator appears in the top bar',
        left: 'Left', center: 'Center', right: 'Right',
        topBar: 'Top bar', panelCpu: 'CPU usage', panelMem: 'Memory usage', panelNet: 'Network speed',
        sections: 'Popup sections', cpu: 'CPU', memory: 'Memory', gpu: 'GPU', network: 'Network',
        disk: 'Disks', battery: 'Battery', system: 'System info',
        extras: 'Extras', temp: 'Show temperatures', publicIp: 'Show public IP',
        publicIpSub: 'Queries api.ipify.org every 30 minutes',
    },
    tr: {
        general: 'Genel', interval: 'Güncelleme aralığı', intervalSub: 'Değerlerin yenilenme sıklığı (milisaniye)',
        position: 'Üst çubuk konumu', positionSub: 'Göstergenin üst çubuktaki yeri',
        left: 'Sol', center: 'Orta', right: 'Sağ',
        topBar: 'Üst çubuk', panelCpu: 'İşlemci kullanımı', panelMem: 'Bellek kullanımı', panelNet: 'Ağ hızı',
        sections: 'Açılır pencere bölümleri', cpu: 'İşlemci', memory: 'Bellek', gpu: 'GPU', network: 'Ağ',
        disk: 'Diskler', battery: 'Pil', system: 'Sistem bilgisi',
        extras: 'Ek seçenekler', temp: 'Sıcaklıkları göster', publicIp: 'Genel IP adresini göster',
        publicIpSub: 'Her 30 dakikada bir api.ipify.org sorgulanır',
    },
};

/**
 * @param {Adw.PreferencesWindow} window preferences window
 * @param {Gio.Settings} settings extension settings
 * @param {object} deps libraries: Adw, Gtk, Gio, GLib
 */
function fillDodoPulsePreferences(window, settings, deps) {
    const {Adw, Gtk, Gio, GLib} = deps;
    const lang = (GLib.get_language_names()[0] || 'en').toLowerCase();
    const t = lang.startsWith('tr') ? PREFS_STRINGS.tr : PREFS_STRINGS.en;

    const page = new Adw.PreferencesPage({title: t.general, icon_name: 'utilities-system-monitor-symbolic'});
    window.add(page);
    window.set_default_size(520, 720);

    const switchRow = (group, key, title, subtitle) => {
        const row = new Adw.ActionRow({title, subtitle: subtitle || ''});
        const sw = new Gtk.Switch({valign: Gtk.Align.CENTER});
        settings.bind(key, sw, 'active', Gio.SettingsBindFlags.DEFAULT);
        row.add_suffix(sw);
        row.activatable_widget = sw;
        group.add(row);
    };

    // General
    const general = new Adw.PreferencesGroup({title: t.general});
    page.add(general);

    const intervalRow = new Adw.ActionRow({title: t.interval, subtitle: t.intervalSub});
    const spin = Gtk.SpinButton.new_with_range(500, 10000, 250);
    spin.valign = Gtk.Align.CENTER;
    settings.bind('update-interval', spin, 'value', Gio.SettingsBindFlags.DEFAULT);
    intervalRow.add_suffix(spin);
    general.add(intervalRow);

    const positions = ['left', 'center', 'right'];
    const posRow = new Adw.ComboRow({
        title: t.position,
        subtitle: t.positionSub,
        model: Gtk.StringList.new([t.left, t.center, t.right]),
    });
    posRow.selected = Math.max(0, positions.indexOf(settings.get_string('panel-position')));
    posRow.connect('notify::selected', () => settings.set_string('panel-position', positions[posRow.selected]));
    general.add(posRow);

    // Top bar
    const topBar = new Adw.PreferencesGroup({title: t.topBar});
    page.add(topBar);
    switchRow(topBar, 'panel-show-cpu', t.panelCpu);
    switchRow(topBar, 'panel-show-memory', t.panelMem);
    switchRow(topBar, 'panel-show-network', t.panelNet);

    // Popup sections
    const sections = new Adw.PreferencesGroup({title: t.sections});
    page.add(sections);
    switchRow(sections, 'show-cpu', t.cpu);
    switchRow(sections, 'show-memory', t.memory);
    switchRow(sections, 'show-gpu', t.gpu);
    switchRow(sections, 'show-network', t.network);
    switchRow(sections, 'show-disk', t.disk);
    switchRow(sections, 'show-battery', t.battery);
    switchRow(sections, 'show-system', t.system);

    // Extras
    const extras = new Adw.PreferencesGroup({title: t.extras});
    page.add(extras);
    switchRow(extras, 'show-temperature', t.temp);
    switchRow(extras, 'show-public-ip', t.publicIp, t.publicIpSub);
}
