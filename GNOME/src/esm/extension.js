// DodoPulse - entry point for GNOME Shell 45+ (ES modules)

import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import Shell from 'gi://Shell';
import Cairo from 'cairo';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

import {DodoPulseExtension} from './core.js';

export default class DodoPulse extends Extension {
    enable() {
        const deps = {GLib, Gio, St, Clutter, Shell, Cairo, Main, PanelMenu, PopupMenu};
        this._dodopulse = new DodoPulseExtension(deps, this.getSettings(),
            this.uuid, () => this.openPreferences());
        this._dodopulse.enable();
    }

    disable() {
        this._dodopulse?.destroy();
        this._dodopulse = null;
    }
}
