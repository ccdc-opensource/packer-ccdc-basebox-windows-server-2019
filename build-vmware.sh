#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ -f /proc/version ]] && [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

export VMVARIANT=vmware
export OUTPUTDIR=$PWD/output/$VMVARIANT
export AUTOUNATTEND_ISO=$OUTPUTDIR/autounattend.iso
export AUTOUNATTEND_ISO_SOURCE=$OUTPUTDIR/autounattend-iso-source
export VAGRANT_OUTPUT=$OUTPUTDIR/packer
export VAGRANT_USER_FINAL_PASSWORD=vagrant

echo 'Cleaning existing output...'
rm -f $OUTPUTDIR

echo 'Creating output directory'
mkdir -p $OUTPUTDIR

echo 'copying scripts and autounattend files'
mkdir -p $AUTOUNATTEND_ISO_SOURCE
cp ./answer_files/server-2019/* $AUTOUNATTEND_ISO_SOURCE/
cp ./unattend-floppy-scripts/* $AUTOUNATTEND_ISO_SOURCE/
cp ./vmxnet3/* $AUTOUNATTEND_ISO_SOURCE/
mkdir -p "$AUTOUNATTEND_ISO_SOURCE/\$WinpeDriver\$"
cp -R ./pvscsi "$AUTOUNATTEND_ISO_SOURCE/\$WinpeDriver\$"

sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" $AUTOUNATTEND_ISO_SOURCE/unattend.xml.template > $AUTOUNATTEND_ISO_SOURCE/unattend.xml
sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" $AUTOUNATTEND_ISO_SOURCE/Autounattend.xml.template > $AUTOUNATTEND_ISO_SOURCE/Autounattend.xml

if [[ $(uname) == "Linux" ]]
then
  if [[ ! -f /usr/bin/genisoimage ]]
  then
    echo "Installing genisoimage, please enter your password"
    sudo apt install genisoimage
  fi
  echo "Creating iso image for autounattend.xml file"
  genisoimage -v -J -rational-rock -input-charset utf-8 -o - \
    $AUTOUNATTEND_ISO_SOURCE/ \
    > $AUTOUNATTEND_ISO
elif [[ $(uname) == "Darwin" ]]
then
  echo "Creating iso image for autounattend.xml file"
  hdiutil makehybrid -o $AUTOUNATTEND_ISO $AUTOUNATTEND_ISO_SOURCE/ -iso -joliet
else
  echo "Can't create iso image for autounattend.xml file"
  exit 1
fi

export PACKER_LOG=1

echo 'building base images'
$PACKER build \
  -only=vmware-iso \
  -except=vsphere,vsphere-template \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/windows-2019' \
  -var 'virtualhw.version=13' \
  ./ccdc-basebox-windows-server-2019.json


mv $VAGRANT_OUTPUT/ccdc-basebox/windows-2019.vmware.box $VAGRANT_OUTPUT/ccdc-basebox/windows-2019.$(date +%Y%m%d).0.vmware_desktop.box
