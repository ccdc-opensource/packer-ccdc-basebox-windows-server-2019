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

if [[ -f answer_files/server-2019/Autounattend.xml ]]; then
  rm answer_files/server-2019/Autounattend.xml
fi
cp answer_files/server-2019/Autounattend.xml.template answer_files/server-2019/Autounattend.xml

if [[ ! -x $WINDOWS_PRODUCT_KEY ]]; then
  echo "Inserting Windows product key in unattended install answer file..."
  sed -i "s/<\!--<Key><\/Key>-->/<Key>$WINDOWS_PRODUCT_KEY<\/Key>/" answer_files/server-2019/Autounattend.xml
fi

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
