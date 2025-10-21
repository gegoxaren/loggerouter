
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

public class LO.Timer : Gtk.Window {

  Gtk.Box layout;
  Gtk.Box button_box;
  Gtk.Label timer_label;
  Gtk.Label text_label;
  Gtk.Button ok_button;
  Gtk.Button close_button;
  
  private int64 _time;
  public int64 time {
    set {
      this._time = value;
    }
    get {
      return this._time;
    }
  }

  private string _text;
  public string text {
    construct set {
      this._text = value;
    }
    get {
      return _text;
    }
  }

  public delegate void ReturnCallback (ExitCode exit_code);
  ReturnCallback callback;

  construct {

    this.width_request = 100;
    this.height_request = 100;
    this.resizable = false;

    layout = new Gtk.Box (Gtk.Orientation.VERTICAL, 5) {
      hexpand = true,
      vexpand = true,
      homogeneous = false,
    };
    button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
      hexpand = true,
      vexpand = false,
      homogeneous = true,
    };

    timer_label = new Gtk.Label ("Time Remanining: 0") {
      vexpand = true,
    };

    text_label = new Gtk.Label (this.text) {
      vexpand = true,
    };

    layout.append (text_label);
    layout.append (timer_label);

    close_button = new Gtk.Button.with_label ("Cancel");
    close_button.clicked.connect (() => {
      _time = -1;
      return_to_caller (ExitCode.CANCEL);
    });
    button_box.append (close_button);

    ok_button = new Gtk.Button.with_label ("OK");
    ok_button.clicked.connect (() => {
      return_to_caller (ExitCode.OK);
    });
    button_box.append (ok_button);

    layout.append (button_box);
    
    this.child = layout;
    this.modal = true;
  }

  public Timer (string text, int64? time, owned ReturnCallback callback) {
    this.text = text;
    this.time = time;
    this.callback = (owned) callback;

    this.text_label.set_text (this.text);
    this.start_timer ();
  }

  public enum ExitCode {
    INVALID,
    OK,
    CANCEL;

    public string to_string () {
      switch (this) {
        case (INVALID):
          return "INVALID";
        case (OK):
          return "OK";
        case (CANCEL):
          return "CANCEL";
        default:
          assert_not_reached ();
      }
    }
  }

  private bool label_update () {
    if (_time <= -1) {
      return false;
    }
    if (_time == 0) {
      return_to_caller (ExitCode.OK);
      return false;
    }
    
    this._time--;

    string text = @"Time Remanining: $(this._time)";
    this.timer_label.set_text (text);


    return true;
  }

  private void start_timer () {
    label_update ();
    GLib.Timeout.add_seconds (1, label_update);
  }

  private void return_to_caller (ExitCode e) {
      assert (this.callback != null);
      this.callback (e);
      this.destroy ();
  }

#if TIMER_DEBUG

  static int main (string[] args) {
    Gtk.init ();
    Gtk.Application app = new Gtk.Application ("com.foobar.test", GLib.ApplicationFlags.FLAGS_NONE);
    app.activate.connect (() => {
      LO.Timer t = new LO.Timer ("Shutting down", 30, (e) => {
        print (@"Got: $(e)\n");
        if (e == LO.Timer.ExitCode.OK) {
          return 0;
        } else {
          return 1;
        }
      });
      t.present ();
      t.show ();
      app.add_window (t);
    });

    return app.run ();
  }

#endif

}
