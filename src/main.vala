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

public const string APP_NAME  = "eu.bato24.gegoxaren.loggeroutr";
public const int APP_VERSION_MAJOR = 0;
public const int APP_VERSION_MINOR = 0;
public static string get_app_version () {
  return @"$APP_VERSION_MAJOR.$APP_VERSION_MINOR";
}

public static string? LO_XDG_ACTIONS_PATH;
public static string? LO_XDG_CONFIG_DIR;
public static string? LO_XDG_CONFIG_PATH;


public static LO.App app;

LO.Options opts;
LO.Settings settings;


int main (string[] args) {
  LO_XDG_CONFIG_DIR = GLib.Environment.get_user_config_dir () + "/loggerouter";
  LO_XDG_ACTIONS_PATH = LO_XDG_CONFIG_DIR + "/actions.ini";
  LO_XDG_CONFIG_PATH = LO_XDG_CONFIG_DIR + "/config.ini";

  opts = LO.Options.get_instance (); // Prevents segfault
  settings = LO.Settings.get_instance ();
  opts.exec_name = args[0];
  app = new  LO.App ();

  return app.run (args);
}



