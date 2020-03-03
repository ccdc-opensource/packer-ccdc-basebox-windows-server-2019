#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

export AUTOUNATTEND_ISO=$PWD/output/autounattend.iso

echo 'Cleaning existing output...'
rm -rf ./output-vmware-iso
rm -f $AUTOUNATTEND_ISO
rm -rf ./output/autounattend-iso-source
rm -rf ./output/packer-windows-2019-vmware

echo 'creating output directory'
mkdir -p output

export VAGRANT_USER_FINAL_PASSWORD=vagrant
sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" ./unattend-floppy-scripts/unattend.xml.template > ./unattend-floppy-scripts/unattend.xml
sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" answer_files/server-2019/Autounattend.xml.template > answer_files/server-2019/Autounattend.xml

echo 'copying scripts and autounattend files'
mkdir -p ./output/autounattend-iso-source
cp ./answer_files/server-2019/* ./output/autounattend-iso-source/
cp ./unattend-floppy-scripts/* ./output/autounattend-iso-source/
cp ./vmxnet3/* ./output/autounattend-iso-source/
mkdir -p './output/autounattend-iso-source/$WinpeDriver$'
cp -R ./pvscsi './output/autounattend-iso-source/$WinpeDriver$/'

if [[ $(uname) == "Linux" ]]
then
  if [[ ! -f /usr/bin/genisoimage ]]
  then
    echo "Installing genisoimage, please enter your password"
    sudo apt install genisoimage
  fi
  echo "Creating iso image for autounattend.xml file"
  genisoimage -v -J -rational-rock -input-charset utf-8 -o - \
    output/autounattend-iso-source/ \
    > $AUTOUNATTEND_ISO
elif [[ $(uname) == "Darwin" ]]
then
  echo "Creating iso image for autounattend.xml file"
  hdiutil makehybrid -o $AUTOUNATTEND_ISO output/autounattend-iso-source/ -iso -joliet
else
  echo "Can't create iso image for autounattend.xml file"
  exit 1
fi

export PACKER_LOG=1

echo 'building base images'
$PACKER build \
  -only=vmware-iso \
  -except=vsphere,vsphere-template \
  -var 'build_directory=./output/' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/windows-2019' \
  -var 'virtualhw.version=13' \
  ./ccdc-basebox-windows-server-2019.json


mv output/ccdc-basebox/windows-2019.vmware.box output/ccdc-basebox/windows-2019.$(date +%Y%m%d).0.vmware_desktop.box
