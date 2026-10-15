// DodoPulse - preferences for GNOME Shell 45+ (ES modules)

import Adw from 'gi://Adw';
import Gtk from 'gi://Gtk';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

import {ExtensionPreferences} from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';

import {fillDodoPulsePreferences} from './prefsCore.js';

export default class DodoPulsePreferences extends ExtensionPreferences {
    fillPreferencesWindow(window) {
        fillDodoPulsePreferences(window, this.getSettings(), {Adw, Gtk, Gio, GLib});
    }
}
