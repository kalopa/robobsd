#!/bin/bash
#
#
set -e

scripts="01_get_source.sh 02_collect_pkgs.sh 03_build_images.sh"
nano_files="alix.nano vagrant.nano wrap.nano"
files="$scripts $nano_files cfg data kernel"

echo "Build started on `date`."
vagrant ssh -c "sudo rm -rf robobsd/cfg robobsd/data robobsd/kernel"
vagrant ssh -c "mkdir -p robobsd/cfg robobsd/data robobsd/kernel"

echo "> Copying build scripts to VM..."
for f in $files
do
	vagrant scp $f :robobsd/
done

for f in $scripts
do
	echo "> Running build script: $f"
	vagrant ssh -c "sudo robobsd/$f"
done

echo "> Copying image files from VM..."
for f in $nano_files
do
	platform=`basename $f .nano`
	echo $platform
	vagrant scp :images/robobsd.$platform.img.gz $HOME/bsdisk/images
done
echo "Build completed on `date`."
exit 0
