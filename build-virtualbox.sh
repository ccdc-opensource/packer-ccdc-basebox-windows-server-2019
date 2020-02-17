#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

echo 'creating output directory'
mkdir -p output

echo 'building base images'
$PACKER build \
  -only=virtualbox-iso \
  -except=vsphere,vsphere-template \
  -var 'vhv_enable=true' \
  -var 'build_directory=./output/' \
  -var 'disk_size=400000' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/windows-2019' \
  ./ccdc-basebox-windows-server-2019.json

mv output/ccdc-basebox/windows-2019.virtualbox.box output/ccdc-basebox/windows-2019.$(date +%Y%m%d).0.virtualbox.box
