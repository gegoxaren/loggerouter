
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

public struct LO.Options{
  public string exec_name;
  public bool version;
  public string config_path;
  public bool config_help;
  public string actions_path;

  private static GLib.Once<LO.Options?> instance;

  public static unowned LO.Options? get_instance () {
    return instance.once (() => {
        return LO.Options ();
    });
  }

  private  Options () {
  }
}
