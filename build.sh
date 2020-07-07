#!/bin/bash
#
#
set -e

mkdir -p log
echo "Build started on `date`." > log/build_output.log
vagrant ssh -c "sudo rm -rf robobsd && mkdir -p robobsd/cfg" >> log/build_output.log 2>&1
files="build_images.sh alix.nano vagrant.nano wrap.nano cfg data kernel"

for f in $files
do
    vagrant scp $f :robobsd/$f >> log/build_output.log 2>&1
done
vagrant ssh -c "sudo robobsd/build_images.sh" >> log/build_output.log 2>&1
echo "Build completed on `date`." >> log/build_output.log
exit 0
