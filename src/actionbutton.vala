/*
   This file is part of LoggerOuter.

 LoggerOuter is free software: you can redistribute it and/or modify it under the
 terms of the GNU Lesser General Public License as published by the Free Software
 Foundation, either version 3 of the License, or (at your option) any later
 version.

 LoggerOuter is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
 License for more details.

 You should have received a copy of the GNU Lessel General Public License
 along with LoggerOuter. If not, see <https://www.gnu.org/licenses/>.
 */

public class LO.ActionButton : Gtk.Button {
// This whole class is cursed. :-)
  Gtk.Image icon;
  Gtk.Box box;
  Gtk.Label widget_label;

  string? exec_action;

  string _button_text;

  void run_action () {

    string[]? argv = null;
    string[] envp = Environ.get ();
    Pid pid;
    try {
      GLib.Shell.parse_argv (exec_action, out argv);

      GLib.Process.spawn_async (null,  argv, envp,
                                GLib.SpawnFlags.DO_NOT_REAP_CHILD | GLib.SpawnFlags.SEARCH_PATH_FROM_ENVP ,
                                null, out pid);
      
    } catch (GLib.SpawnError e) {
      LO.present_dialog ("ERROR: %s\n", e.message);
    } catch (GLib.ShellError e) {
      LO.present_dialog ("ERROR: %s\n", e.message);
    }
    app.try_quit ();
  }


  public ActionButton (ActionEntry action) {
    this.box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
      homogeneous = false,
    };
    
    if (action.icon != null) {
      this.icon = new Gtk.Image () {
        vexpand = false,
        hexpand = false,
        pixel_size = 28,
        width_request = 28,
        height_request = 28,
      };
      string _icon_name;
      if (!action.icon_is_path) {
        icon.icon_name = action.icon;
      } else {
        _icon_name = strip_prelude_of_path (action.icon);
        this.icon.set_from_file (_icon_name);
      }
      box.append (icon);
    }

    if (action.text != null) {
      _button_text = action.text;
    } else {
      _button_text = action.group;
    }

    this.exec_action = action.exec;

    this.widget_label = new Gtk.Label (_button_text) {
      hexpand = true,
      vexpand = true,
      halign = Gtk.Align.CENTER,
      valign = Gtk.Align.CENTER,
      margin_end = 28,
    };
    box.append (widget_label);
    this.set_child (this.box);

    this.clicked.connect (() => {
      var timer = new LO.Timer (this._button_text, 15, (e) => {
        if (e == LO.Timer.ExitCode.OK) {
            this.run_action ();
        }
      });
      timer.set_transient_for (app.get_active_window ());
      timer.show ();
    });

  }

  construct {
    this.focusable = true;
  }

}
