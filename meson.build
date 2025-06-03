project('loggerouter', 'c','vala',
  version : '0.1',
  default_options : ['c_std=c17','warning_level=3'])

glib_dep = dependency ('glib-2.0', required: true)
gtk_dep = dependency ('gtk4', required: true)
gio_dep = dependency ('gio-2.0', required: true)
gee_dep = dependency ('gee-0.8', required: true)

subdir ('src')

exe = executable('loggerouter', source_files,
  dependencies : [glib_dep, gtk_dep, gio_dep, gee_dep],
  install : true)

test('basic', exe)
