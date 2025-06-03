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

public struct LO.ActionEntry {
  string group; /*< The "[Group]" heading*/
  string? text; /*< the "Text=foo bar" key*/
  string exec; /*< the "Exec=baz buz" key*/
  string? icon; /*< icon name or path. "Icon="*/
  bool icon_is_path; /*< wether or not "icon" is a path or an icon name. */

  public string to_string () {
    string outstr = @"[$(group)]\nText=";
    if (text != null) {
      outstr += text;
    }
    outstr += @"\nExec=$(exec)\n";
    if (icon != null) {
      outstr += @"Icon=$(icon)\n";
    } else {
      outstr += "Icon=\n";
    }
    outstr += @"# Icon is path: $(icon_is_path)\n";
    return outstr;
  }
}

public struct LO.Action {
  Gee.ArrayList<LO.ActionEntry?> entries;
  KeyFile? actions_key_file;
  string? actions_file;


  // Standard way of loadin settings file
  public Action.from_xdg () {
    actions_key_file = new KeyFile ();

    try {
      actions_key_file.load_from_file (LO_XDG_ACTIONS_PATH, GLib.KeyFileFlags.NONE);
    } catch (GLib.FileError e) {
      string message = "ERROR: Could not load configuration file.\n" +
                       "Have you created one? See \"--help\" for more information.\n" +
                       @"Error: $(e.message)\n";
      GLib.stderr.printf (message);
      LO.prensent_dialog (message);
      GLib.Process.exit (33);
    } catch (GLib.KeyFileError e) {
      string message = "ERROR: Could not load configuration file.\n" +
                       " ini file error.\n" +
                       @"Error: $(e.message)\n";
      GLib.stderr.printf (message);
      LO.prensent_dialog (message);
      GLib.Process.exit (34);
    }

    parse_keyfile ();
  }

  // For use with --config_file
  public Action.from_file (string actions_path) {
    //absolute path:
    actions_key_file = new KeyFile ();

    this.actions_file = LO.resolve_path (actions_path);

    try {
      actions_key_file.load_from_file (actions_file, GLib.KeyFileFlags.NONE);
    } catch (GLib.FileError e) {
      string message = @"ERROR: Could not open file \"$(actions_file)\":\n" +
        @"$(e.message)\n";
      GLib.stderr.printf (message);
      prensent_dialog (message);
      GLib.Process.exit (37);
    } catch (GLib.KeyFileError e) {
      string message =
        @"ERROR: Something went wrong whilst loading the key-file \"$(actions_file)\":\n" +
        @"$(e.message)\n";
      GLib.stderr.printf (message);
      prensent_dialog (message);
      GLib.Process.exit (38);
    }

    parse_keyfile ();
  }

  // Parse the KeyFile. 
  void parse_keyfile ()
  requires (this.actions_key_file != null) {
     /* The keyfile stucture is like this:
      * Each action has it's own group, the groups name is the name of the action
      * in the UI.
      * the key "exec" is used what is run when the button in pressed.
      *
      * Example:
      *
      * [Logout]
      * Text=Logout session
      * Exec=swaymsg exit
      */
    string[] group_list = actions_key_file.get_groups ();

    if (group_list.length < 1) { // No groups
      string message = @"ERROR: The keyfile $(this.actions_file) is empty.\n" +
                        "Please add actions to the keyfile (ini-file).\n";
      GLib.stderr.printf (message);
      LO.prensent_dialog (message);
      GLib.Process.exit (35);
    }

    entries = new Gee.ArrayList<LO.ActionEntry?> ();

    foreach (string _group in group_list) {
      string? _text = null;
      string? _icon = null;
      try {
        if (actions_key_file.has_key (_group, "Text")) {
          _text = actions_key_file.get_string (_group, "Text");
        }
        string? _exec = actions_key_file.get_string (_group, "Exec");
        if (actions_key_file.has_key (_group, "Icon"))  {
          _icon = actions_key_file.get_string (_group, "Icon");
        }
        bool _icon_is_path = false;
        if (_icon != null) {
          if (str_starts_with (_icon, "file://")) {
            _icon_is_path = true;
          }
        }
        var entry = LO.ActionEntry () {
          group = _group,
          text = _text,
          exec = _exec,
          icon = _icon,
          icon_is_path = _icon_is_path
        };
        entries.add (entry);
      } catch (GLib.KeyFileError e) {
        string message = "ERROR: An error has occurred whilst parsing the key-file:\n" +
                         @"Error: $(e.message)\n";
        prensent_dialog (message);
        stderr.printf (message);
        GLib.Process.exit (36);
      }
    }
  }

  public Gee.ArrayList<LO.ActionEntry?>? get_entries () {
    if (this.entries == null) {
      GLib.stderr.printf ("ERROR: enteties list does not seem to be initialised!\n");
      return null;
    }
    return this.entries;
  }

}
