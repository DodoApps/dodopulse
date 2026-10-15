// DodoPulse - preferences for GNOME Shell 43 / 44 (legacy imports)

/* exported init fillPreferencesWindow */

const {Adw, Gtk, Gio, GLib} = imports.gi;
const ExtensionUtils = imports.misc.extensionUtils;

const Me = ExtensionUtils.getCurrentExtension();
const PrefsCore = Me.imports.prefsCore;

function init() {
}

function fillPreferencesWindow(window) {
    PrefsCore.fillDodoPulsePreferences(window, ExtensionUtils.getSettings(), {Adw, Gtk, Gio, GLib});
}
