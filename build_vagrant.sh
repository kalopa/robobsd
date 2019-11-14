#!/bin/sh
chown -R root:wheel ./cfg ./data
chown -R 1000:1000 ./data/robobsd
chmod 755 ./data/robobsd
chmod -R go-rwx ./data/robobsd/.ssh
sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c ./vagrant.nano
exit 0
