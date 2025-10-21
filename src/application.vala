
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

public class LO.Application : Gtk.Application {

  LO.Actions actions;
  public Gtk.Window? window;
  Gtk.ListBox? list_box;

  public bool can_quit = true;

  public void try_quit () {
    if (can_quit) {
      app.quit ();
    }
  }


  construct {
    GLib.OptionEntry[] options = {
      {"version", 'v', OptionFlags.NONE, OptionArg.NONE, null,
      "Display version number.", null},

      {"config", 0, OptionFlags.NONE, OptionArg.FILENAME, null,
      "Path to configuration file." , "<path/to/config.ini>"},

      {"actions", 0, OptionFlags.NONE, OptionArg.FILENAME, null,
      "Path to actions file." , "<path/to/actions.ini>"},

      {"help-actions", 0, OptionFlags.NONE, OptionArg.NONE, null,
      "Print extra information about action configuration files.", null},

      {"help-config", 0, OptionFlags.NONE, OptionArg.NONE, null,
      "Print information on how to configure app specific things.", null},

      {null, 0, 0, 0, null, null}, 
    };
    application_id = APP_NAME;
    add_main_option_entries (options);

  }

  public override int handle_local_options (VariantDict options) {
    if (options.contains ("version")) {
      print (get_app_version ());
      return 0;
    }
    if (options.contains ("help-actions")) {
      print_actions_help ();
      return 0;
    }

    if (options.contains ("help-config")) {
      print_config_help ();
      return 0;
    }

    if (options.contains ("actions")) {
      opts.actions_path = options.lookup_value ("actions", null).get_bytestring ();
    }

    if (options.contains ("config")) {
      opts.config_path = options.lookup_value ("config", null).get_bytestring ();
    }

    return -1; // Let the base class handle the rest.
  }

  public Application () {

  }

  public override void activate () {
    //var settings = Settings.get_instance ();
    //var _opts = Options.get_instance ();

    window = new Gtk.ApplicationWindow (this) {
      title = "LoggerOuter",
      width_request = 500,
      height_request = 500,
      resizable = false,
    };

    var _action = new GLib.SimpleAction ("quit", null);

    _action.activate.connect (() => {this.quit ();} );
    this.add_action (_action);
    this.set_accels_for_action ("app.quit", {"Escape","q",null});

    if (opts.config_path != null) {
      settings.load_settings (opts.config_path);
    } else {
      settings.load_setting_from_xdg ();
    }

    if (opts.actions_path != null) {
        stdout.printf (settings.to_string ());
      actions = LO.Actions.from_file (opts.actions_path);
    } else {
      actions = LO.Actions.from_xdg ();
    }


    list_box  = new Gtk.ListBox () {
      margin_top = 50,
      margin_bottom = 50,
      margin_start = 100,
      margin_end = 100,
      show_separators = true,
      activate_on_single_click = true,
    };
    list_box.row_activated.connect ((row) => {
      row.child.activate ();
    });


    add_buttons (actions.get_entries ());

    window.set_child (list_box);
    window.present ();
    window.set_focus (list_box.get_selected_row  ());

    bool dark_theme = settings.dark_theme;
    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = dark_theme;
  }


  void add_buttons (Gee.ArrayList<LO.ActionEntry?> list) {
    foreach (ActionEntry entry in list) {
      stdout.printf ("%s\n\n", entry.to_string ());
      var btn = new LO.ActionButton (ref entry);
      this.list_box.append (btn);
    }
  }

  void print_actions_help () {
    string message = """
Help about how to configure actions for %s.

The standard locaton is "$XDG_USER_HOME/loggerouter/actions.ini", but
you can specify your own location using the --actions= option.

Each "group" in the ini file will be displayed like a button in the application,
and will take the name of the group. Thus it is of great importance that the group
is unique, as groups of the same name will be merged.

Each group must have an "Exec=" key.

There is an optional "Text=" key that can be set.

An optional "Icon=" key can be set. Normaly this uses the GTK icon handling mechanism,
but you can prefix with "file://" and the app will try to use that image intead.

An example of how this may work is as follows:
[logout]
Text=Logout session.
Exec=swaymsg exit
Icon=system-log-out-symbolic
""";
    GLib.stdout.printf (message, opts.exec_name);
  }

  void print_config_help () {
    string message = """
Help for how to configure %s.

The standard location is "$XDG_USER_HOME/loggerouter/config.ini", but
you can specify your own location using the --config= option.

The ini file has only one section: [Main]

Valid keys are:
DarkTheme=      # Do you want to use a dark theme?
""";
    GLib.stdout.printf (message, opts.exec_name);
  }


}
