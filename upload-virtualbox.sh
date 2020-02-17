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

BOX_NAME="ccdc-basebox/centos-7.7"
PROVIDER="virtualbox"
BOX_VERSION="$(date +%Y%m%d).0"
FILENAME=$BOX_NAME.$BOX_VERSION.$PROVIDER.box
PATH_TO_FILE=output/$FILENAME
curl -H "X-JFrog-Art-Api:$ARTIFACTORY_API_KEY" -T $PATH_TO_FILE "https://artifactory.ccdc.cam.ac.uk/ccdc-vagrant-repo/$FILENAME;box_name=$BOX_NAME;box_provider=$PROVIDER;box_version=$BOX_VERSION"