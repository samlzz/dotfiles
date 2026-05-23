#!/usr/bin/env python

import sys
import gi
import subprocess
from os import path
gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Gtk, Adw # noqa: E402

Adw.init()

class TimerWindow(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Set a timer")
        self.set_default_size(300, 180)
        self.set_resizable(False)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20, margin_top=10, margin_bottom=10, margin_start=20, margin_end=20)

        # Hours
        self.hours = Gtk.SpinButton()
        self.hours.set_range(0, 23)
        self.hours.set_increments(1, 1)
        self.hours.set_value(0)
        self.hours.set_digits(0)
        self.hours.set_hexpand(True)

        # Minutes
        self.minutes = Gtk.SpinButton()
        self.minutes.set_range(0, 59)
        self.minutes.set_increments(1, 1)
        self.minutes.set_value(15)
        self.minutes.set_digits(0)
        self.minutes.set_hexpand(True)

        # Layout horizontal
        row = Gtk.Box(spacing=10)
        row.append(Gtk.Label(label="Hours:", xalign=0))
        row.append(self.hours)
        row.append(Gtk.Label(label="Minutes:", xalign=0))
        row.append(self.minutes)

        button = Gtk.Button(label="Start timer")
        button.connect("clicked", self.start_timer)

        box.append(row)
        box.append(button)
        self.set_content(box)

    def start_timer(self, _):
        h = int(self.hours.get_value())
        m = int(self.minutes.get_value())
        delay = h * 3600 + m * 60
        if delay > 0:
            subprocess.Popen([
                path.expandvars("$XDG_CONFIG_HOME/waybar/scripts/timer-notify.sh"), str(delay)
            ])
            subprocess.Popen([
                "notify-send", f"Programmed popup in {round(delay / 60, 1)} min"
            ])
        self.close()


class TimerApp(Adw.Application):
    def __init__(self):
        super().__init__(application_id="dev.local.timerpicker.GtkApplication")
        self.connect("activate", self.on_activate)

    def on_activate(self, app):
        win = TimerWindow(self)
        win.present()


def main():
    app = TimerApp()
    sys.exit(app.run(sys.argv))

if __name__ == "__main__":
    main()


