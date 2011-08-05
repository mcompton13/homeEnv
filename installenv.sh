#!/bin/bash

DEST_DIR_BASE=${HOME}

# Go to the directory containing this script
pushd "${0%/*}"

# The home environment is expected to be in a directory call "home" with the
# same parent directory as this script.
HOME_ENV_ROOT=$(pwd)/home

if [[ ! -d ${HOME_ENV_ROOT} ]]; then
    echo "Home environment root directory not found at '${HOME_ENV_ROOT}'"
    exit
fi

echo "Installing from '${HOME_ENV_ROOT}' to '${DEST_DIR_BASE}'"
pushd ${HOME_ENV_ROOT}


function relativePath () {
    if [[ "$1" == "$2" ]]
    then
        echo "."
        return
    fi

    local IFS="/"

    local newpath=""
    local current=($1)
    local absolute=($2)

    local abssize=${#absolute[@]}
    local cursize=${#current[@]}

    while [[ ${absolute[level]} == ${current[level]} ]]
    do
        (( level++ ))
        if (( level > abssize || level > cursize ))
        then
            break
        fi
    done

    for ((i = level; i < cursize; i++))
    do
        if ((i > level))
        then
            newpath=$newpath"/"
        fi
        newpath=$newpath".."
    done

    for ((i = level; i < abssize; i++))
    do
        if [[ -n $newpath ]]
        then
            newpath=$newpath"/"
        fi
        newpath=$newpath${absolute[i]}
    done

    echo "$newpath"
}


find . -type d | while read d; do
   destDir=${DEST_DIR_BASE}${d#.}
   echo "Creating '${destDir}'"
   mkdir -p "${destDir}"
done

find . -type f | while read f; do
    fileName="${f#.}"
    fromFileName="${HOME_ENV_ROOT}${fileName}"
    toFileName="${DEST_DIR_BASE}${fileName}"
    # Check to see if the destination is already a link to the correct file
    if [ -h ${toFileName} ] && [ "$(readlink -f ${toFileName})" = "${fromFileName}" ]; then
        # Already linked to the correct file, skip
        echo "File '${toFileName}' already linked, skipping"
    else
        # Need to make the link
        toFileDir="${toFileName%/*}"
        fromFileNameRel=$(relativePath "${toFileDir}" "${fromFileName}")
        pushd "${toFileDir}"
        echo "Linking '${fromFileNameRel}' to '${toFileName}' in '$(pwd)'"
        ln -b -s "${fromFileNameRel}" "${toFileName}"
        popd
    fi
done

popd
popd
