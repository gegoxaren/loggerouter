LoggerOuter


This is a simple tool to display a logout prompt...
Or use it as a launcher? I don't care.

Please see the provided configuration exampels
(test_actions.ini and test_config.ini).


Building/Installation

$ mkdir build && cd build
$ meson setup --bindir=~/.local/bin/ .. 
$ ninja
$ ninja install
$ # installing the configuration files
$ mkdir -p ~/.config/loggerouter
$ cp actions.ini ~/.config/loggerouter/
$ cp config.ini ~/.config/loggerouter/



Github code repo:
https://github.com/gegoxaren/loggerouter

private repo:
https://gegoxaren.bato24.eu/bzr/loggerouter/trunk/files
