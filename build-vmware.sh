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

echo 'cleaning up intermediate output'
rm -rf ./output//packer-centos-7.7-x86_64-vmware

VAGRANT_USER_FINAL_PASSWORD=vagrant
sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" ./unattend-floppy-scripts/unattend.xml.template > ./unattend-floppy-scripts/unattend.xml
#sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" answer_files/server-2019/Autounattend.xml.template > answer_files/server-2019/Autounattend.xml

echo 'building base images'
$PACKER build \
  -only=vmware-iso \
  -except=vsphere,vsphere-template \
  -var 'build_directory=./output/' \
  -var 'disk_size=400000' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/windows-2019' \
  -var 'virtualhw.version=13' \
  ./ccdc-basebox-windows-server-2019.json


mv output/ccdc-basebox/windows-2019.vmware.box output/ccdc-basebox/windows-2019.$(date +%Y%m%d).0.vmware_desktop.box
