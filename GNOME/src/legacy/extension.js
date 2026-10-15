// DodoPulse - entry point for GNOME Shell 43 / 44 (legacy imports)

/* exported init */

const {GLib, Gio, St, Clutter, Shell} = imports.gi;
const Cairo = imports.cairo;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const ExtensionUtils = imports.misc.extensionUtils;

const Me = ExtensionUtils.getCurrentExtension();
const Core = Me.imports.core;

class Extension {
    enable() {
        const deps = {GLib, Gio, St, Clutter, Shell, Cairo, Main, PanelMenu, PopupMenu};
        this._dodopulse = new Core.DodoPulseExtension(deps, ExtensionUtils.getSettings(),
            Me.metadata.uuid, () => ExtensionUtils.openPrefs());
        this._dodopulse.enable();
    }

    disable() {
        this._dodopulse?.destroy();
        this._dodopulse = null;
    }
}

function init() {
    return new Extension();
}
