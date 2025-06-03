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

public struct LO.Settings {

  const string CONFIG_INI_NAMESPACE_MAIN = "Main";

  string? config_path;
  GLib.KeyFile? key_file;

  private static GLib.Once<LO.Settings?> instance;

  public bool? dark_theme;

  public static unowned LO.Settings? get_instance () {
    return instance.once (() => {
      return LO.Settings ();
    });
  }

  private Settings () {}

  public void load_settings (string config_path) {
    key_file = new GLib.KeyFile ();
  this.config_path = config_path;
    parse_key_file ();
  }

  public void load_setting_from_xdg () {
    key_file = new GLib.KeyFile ();
    this.config_path = LO_XDG_CONFIG_PATH;
  }

  private void parse_key_file ()
  requires (key_file != null) {
    try {
      key_file.load_from_file (this.config_path, GLib.KeyFileFlags.NONE);
    } catch (GLib.FileError e) {
      string message = @"ERROR: $(e.message)\n";
      stderr.printf (message);
    } catch (GLib.KeyFileError e) {
      string message = @"ERROR: $(e.message)\n";
      stderr.printf (message);
    }

    try {
      if( key_file.has_key (CONFIG_INI_NAMESPACE_MAIN, "DarkTheme") ) {
        this.dark_theme = key_file.get_boolean (CONFIG_INI_NAMESPACE_MAIN, "DarkTheme");
      }
    } catch (GLib.KeyFileError e) {
      string message = @"ERROR: $(e.message)\n";
      stderr.printf (message);
    }
  }
}
