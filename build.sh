#!/bin/bash
#
#
set -ex

scripts="01_collect_pkgs.sh 02_get_source.sh 03_build_world.sh 04_build_kernels.sh"
nano_files="alix.nano vagrant.nano wrap.nano"
files="$scripts $nano_files cfg data kernel"

echo "Build started on `date`."
vagrant ssh -c "sudo rm -rf robobsd && mkdir robobsd"

for f in $files
do
    vagrant scp $f :robobsd/$f
done
for f in $scripts
do
	echo "> Running build script: $f"
	vagrant ssh -c "sudo robobsd/$f"
done
echo "Build completed on `date`."
exit 0
