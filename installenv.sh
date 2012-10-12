#!/bin/bash

# Default to user's home dir if a destination is not specified as a parameter.
DEST_DIR_BASE=${1:-${HOME}}

# Make the destination dir, and get the absolute path to the destination dir.
mkdir -p "${DEST_DIR_BASE}"
pushd "${DEST_DIR_BASE}" >&-
DEST_DIR_BASE=$(pwd)
popd >&-

# Go to the directory containing this script
pushd "${0%/*}" >&-

# The home environment is expected to be in a directory named "home" with the
# same parent directory as this script.
HOME_ENV_ROOT=$(pwd)/home

if [[ ! -d ${HOME_ENV_ROOT} ]]; then
    echo "Home environment root directory not found at '${HOME_ENV_ROOT}'"
    exit
fi

echo "Installing from '${HOME_ENV_ROOT}' to '${DEST_DIR_BASE}'"
pushd ${HOME_ENV_ROOT} >&-

# From http://stackoverflow.com/questions/2564634/bash-convert-absolute-path-into-relative-path-given-a-current-directory
# Calculates the relative path for inputs that are absolute paths or relative
# paths without . or ..
#
# Usage: relativePath from to
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


function getLinkAbsoluteFilename {
    local filename="${1##*/}"
    local fileDir="${1%/*}"
    pushd "${fileDir}" >&-
    local linkFullFilename=$(readlink "${filename}")
    local linkFilename="${linkFullFilename##*/}"
    local linkDir="${linkFullFilename%/*}"

    if [ -f "${linkFullFilename}" ]; then
        pushd "${linkDir}" >&-
        if [ -f "${linkFilename}" ]; then
            echo "$(pwd)/${linkFilename}"
        fi
        popd >&-
    fi
    popd >&-
}


function backupFile {
    local filename=("${1}")
    local version=0

    while [ -f "${filename}~${version}" ]; do
        (( version++ ))
    done

    cp "${filename}" "${filename}~${version}"
}


function backupLn {
    local fromFilename=("${1}")
    local toFilename=("${2}")

    if [ -f "${toFilename}" ]; then
        backupFile "${toFilename}"
        rm -f "${toFilename}"
    fi

    ln -s "${fromFilename}" "${toFilename}"
}


find . -type d | while read d; do
   destDir=${DEST_DIR_BASE}${d#.}
   echo "Creating '${destDir}'"
   mkdir -p "${destDir}"
done

# Get list of all the files, ignoring VIM's temp files .swp, .swo, and .swn
installFiles=$(find . -type f -a ! -name ".*.sw[pon]")
for f in ${installFiles}; do
    filename="${f##*/}"
    filePathname="${f#.}"
    fromFilename="${HOME_ENV_ROOT}${filePathname}"
    toFilename="${DEST_DIR_BASE}${filePathname}"
    # Check to see if the destination is already a link to the correct file
    if [ -h ${toFilename} ] && [ "$(getLinkAbsoluteFilename ${toFilename})" = "${fromFilename}" ]; then
        # Already linked to the correct file, skip
        echo "File '${toFilename}' already linked, skipping"
    else
        # Need to make the link
        toFileDir="${toFilename%/*}"
        fromFilenameRel=$(relativePath "${toFileDir}" "${fromFilename}")
        pushd "${toFileDir}" >&-
        echo "Linking '${fromFilenameRel}' to '${toFilename}' in '$(pwd)'"
        backupLn "${fromFilenameRel}" "${toFilename}"
        popd >&-
    fi
done

popd >&-
popd >&-

