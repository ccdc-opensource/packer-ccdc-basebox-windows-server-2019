#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

echo 'creating output directory'
mkdir -p output

echo 'building base images'
packer build \
  -only=vmware-iso \
  -except=vagrant,vsphere,vsphere-template \
  -var 'build_directory=./output/' \
  -var 'disk_size=400000' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/windows-2019' \
  -var 'virtualhw.version=13' \
  ./ccdc-basebox-windows-server-2019.json

