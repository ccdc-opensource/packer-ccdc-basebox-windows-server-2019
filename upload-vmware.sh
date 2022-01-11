#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$ARTIFACTORY_API_KEY" ]
then
  echo "Please head to https://artifactory.ccdc.cam.ac.uk/"
  echo "Log in, select the ccdc-vagrant-repo repository in the Set me up box, type your password in the password box"
  echo "Select the key that appears after curl -H 'X-JFrog-Art-Api:'"
  echo "In order for this script to work, you need to export ARTIFACTORY_API_KEY='key'"
  exit 1
fi

pushd $DIR

export VMVARIANT=vmware
export OUTPUTDIR=$PWD/output/$VMVARIANT
export VAGRANT_OUTPUT=$OUTPUTDIR/packer
BOX_NAME="ccdc-basebox/windows-2019"
PROVIDER="vmware_desktop"
BOX_VERSION="$(date +%Y%m%d).0"
FILENAME=$BOX_NAME.$BOX_VERSION.$PROVIDER.box
PATH_TO_FILE=$VAGRANT_OUTPUT/$FILENAME
echo "pushing box to artifactory"

# Possible values are: INFO, ERROR, and DEBUG.
export JFROG_CLI_LOG_LEVEL=DEBUG

export JFROG_CLI_OFFER_CONFIG=false

jfrog rt u \
  --password "$ARTIFACTORY_API_KEY" \
  --target-props "box_name=$BOX_NAME;box_provider=$PROVIDER;box_version=$BOX_VERSION" \
  --retries 100 \
  --url "https://artifactory.ccdc.cam.ac.uk/artifactory" \
  $PATH_TO_FILE \
  "ccdc-vagrant-repo/$FILENAME"
