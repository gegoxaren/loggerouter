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

namespace LO {


  public  static string strip_prelude_of_path (string str) {
    string tmp_str;
    if (str_starts_with (str, "file://")) {
      print ("Icon is path!\n");
      tmp_str = str.substring (7).escape (null);
      print (@"$(tmp_str)\n");
    } else{
      tmp_str = str;
    }
    return tmp_str;
  }

  public static string str_escape_enviorment_variables (string str ) {
    StringBuilder builder = new StringBuilder ();
    var enviorment = GLib.Environ.@get ();

    if (str_starts_with (str, "/")) {
      builder.append_c ('/');
    }

    var tokens = str.split ("/");
    builder.append (tokens[0]);

    for (size_t i = 1; i <= tokens.length; i++) {
      var t = tokens[i];

      if (str_starts_with (str, "$")) {
        builder.append (GLib.Environ.get_variable (enviorment, t));
      } else {
        builder.append (t);
      }
    }

    if (str_ends_with (str, "/")) {
      builder.append_c ('/');
    }

    return builder.str;
  }


  // Fake old style gtk_main () from old GTK.
  void fake_gtk_main () {
    if ( Gtk.Window.get_toplevels () != null ){
      while (((GLib.ListStore)Gtk.Window.get_toplevels ()).get_n_items () > 0) {
        GLib.MainContext.default ().iteration (true);
      }
    }
  }

  void __dialog_response (int id) {
    dia.destroy ();
    app.can_quit = true;
  }

#if GTK_4_10
  Gtk.AlertDialog dia;
#else
  Gtk.MessageDialog dia;
#endif

  // Easier presentation of dialog...
  void present_dialog (string? format, ...) {
    bool use_fake_main_loop = false;
    Gtk.Window? parent = null;
    if (!Gtk.is_initialized ()) {
      Gtk.init ();
      use_fake_main_loop = true;
    } else {
      parent = app.window;
      app.can_quit = false;
      app.hold ();
    }
    string message = format.vprintf (va_list ());
    GLib.stderr.printf (message);
#if GTK_4_10
    dia = new Gtk.AlertDialog (message, null);
    dia.response.connect (__dialog_responce );
    dia.show (parent);
#else
    dia = new Gtk.MessageDialog (parent,
                                     Gtk.DialogFlags.USE_HEADER_BAR,
                                     Gtk.MessageType.ERROR,
                                     Gtk.ButtonsType.CANCEL, message, null);
    dia.response.connect (__dialog_response );
    dia.present ();
#endif
    if (use_fake_main_loop) {
      fake_gtk_main ();
    } else {
      app.release ();
    }
  }

  bool str_starts_with (string stack, string needle) {
    if (stack.length < needle.length ) {
      return false;
    }
    for (long i = 0; i < needle.length; i++) {
      if (stack[i] != needle[i]) {
        return false;
      }
    }
    return true;
  }

  bool str_ends_with (string stack, string needle) {
    if (stack.length < needle.length) {
      return false;
    }
    long stack_len = stack.length;
    for (long i = needle.length; i > 0; i--) {
      if (stack[i] != needle[stack_len]) {
        return false;
      }
      stack_len--;
    }
    return true;
  }


  string resolve_path (string path) {
    string base_dir;
    string tmp_file;
    string out_path;

    if (path[0] == '/') {
      // Absolute Path
      out_path = path;
    } else {
      if (str_starts_with (path, "~/")) {
        base_dir = GLib.Environment.get_home_dir ();
        long index = path.index_of_char ('/');

       out_path = base_dir +  path.substring (index);

      } else {
        base_dir = GLib.Environment.get_current_dir () + "/";
        // either "./" or nothing at start.
        if (str_starts_with (path, "./")) {

          long index = path.index_of_char ('/') + 1;
          tmp_file = path.substring (index);

        } else {
          tmp_file = path;
        }

        out_path= base_dir + tmp_file;
      }
    }
    return out_path;
  }
}
