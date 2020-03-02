#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pushd $DIR

if [[ "$( grep Microsoft /proc/version )" ]]; then
  PACKER="packer.exe"
else
  PACKER="packer"
fi

if [[ ! -e ./vsphere-environment-do-not-add ]]
then
  echo "Please add a vsphere-environment-do-not-add file to set up the environment variables required to deploy"
  echo "These vary based on the target VMWare server. The list can be found at the bottom of the packer template."
  return 1
fi
source ./vsphere-environment-do-not-add

echo 'creating output directory'
mkdir -p output
echo 'Cleaning output directory'
rm -rf ./output-vmware-iso

sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" unattend-floppy-scripts/unattend.xml.template > unattend-floppy-scripts/unattend.xml
sed -e "s#<Value>vagrant</Value>#<Value>$VAGRANT_USER_FINAL_PASSWORD</Value>#" answer_files/server-2019/Autounattend.xml.template > answer_files/server-2019/Autounattend.xml

export PACKER_LOG='1'
echo 'building base images'
$PACKER build \
  -only=vmware-iso \
  -except=vagrant \
  -var 'customise_for_buildmachine=1' \
  -var 'build_directory=./output/' \
  -var 'cpus=2' \
  -var 'memory=4096' \
  -var 'box_basename=ccdc-basebox/windows-2019' \
  -var 'vmx_remove_ethernet_interfaces=false' \
  -var 'virtualhw.version=13' \
  ./ccdc-basebox-windows-server-2019.json

