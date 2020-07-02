#!/bin/bash
#
#
set -e

mkdir -p log
vagrant ssh -c "sudo rm -rf robobsd && mkdir -p robobsd/cfg" > log/file_copy.log 2>&1
for f in *
do
    vagrant scp $f :robobsd/$f >> log/file_copy.log 2>&1
done
vagrant ssh -c "sudo robobsd/build_images.sh" > log/image_build.log 2>&1
exit 0
