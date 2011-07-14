#!/bin/bash

DEST_DIR_BASE=${HOME}
# FIXME: Simplistic, need to figure out directory in general
HOME_ENV_ROOT=$(pwd)/home

echo "Installing from ${HOME_ENV_ROOT}"

pushd ${HOME_ENV_ROOT}

find . -type d | while read d; do
   destDir=${DEST_DIR_BASE}${d#.}
   echo "Creating '${destDir}'"
   install -b -d "${destDir}"
done

find . -type f | while read f; do
    fileName="${f#.}"
    fromFileName="${HOME_ENV_ROOT}${fileName}"
    toFileName="${DEST_DIR_BASE}${fileName}"
    echo "Linking '${fromFileName}' to '${toFileName}'"
    ln -s "${fromFileName}" "${toFileName}"
done
