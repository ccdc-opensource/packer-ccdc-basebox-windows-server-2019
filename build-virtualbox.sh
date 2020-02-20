#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
  VBOXMANAGE="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
else
  PACKER="packer"
  VBOXMANAGE="vboxmanage"
fi

echo 'Cleaning existing output...'
rm -rf ./output-virtualbox-iso
# rm -rf ./output/packer-windows-virtualbox
EXISTINGVM="$( "$VBOXMANAGE" list vms | grep packer-virtualbox-iso | sed -e 's/\ .*//' | sed -e 's/"//g' )"
if [[ $EXISTINGVM != "" ]]; then
  echo "Purging existing VM $EXISTINGVM"
  "$VBOXMANAGE" unregistervm $EXISTINGVM --delete
fi
echo 'Removing any left over disk images from previous builds...'
rm -f ./builds.vmdk
rm -f ./x_mirror.vmdk

if [[ -f answer_files/Autounattend.xml ]]; then
  rm answer_files/Autounattend.xml
fi
cp answer_files/Autounattend.xml.template answer_files/Autounattend.xml

if [[ ! -x $WINDOWS_PRODUCT_KEY ]]; then
  echo "Inserting Windows product key in unattended install answer file..."
  sed -i "s/<\!--<Key><\/Key>-->/<Key>$WINDOWS_PRODUCT_KEY<\/Key>/" answer_files/Autounattend.xml
fi

echo 'Creating output directory'
mkdir -p output

echo 'Building base images'
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
