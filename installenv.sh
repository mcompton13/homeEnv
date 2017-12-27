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

# Get OS info from uname in ALL CAPS
UNAME="$(tr '[:lower:]' '[:upper:]' <<< $(uname -s))"

if [ "${UNAME}" == "DARWIN" ]; then
    OS_TYPE="bsd"
    OS_NAME="darwin"
elif [ "${UNAME}" == "LINUX" ]; then
    OS_TYPE="linux"
    OS_NAME="ubuntu"
fi


echo "Detected OS Type=${OS_TYPE} and Name=${OS_NAME}"

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
    local level=0

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

    echo "Backup ${filename} to ${filename}~${version}"

    mv "${filename}" "${filename}~${version}"
}


function backupLn {
    local fromFilename=("${1}")
    local toFilename=("${2}")

    echo "Linking ${fromFilename} to ${toFilename} in $(pwd)"

    if [ -h "${toFilename}" ]; then
        # Just remove links
        echo "Removing existing link ${toFilename}"
        rm -f "${toFilename}"
    elif [ -f "${toFilename}" ]; then
        backupFile "${toFilename}"
    fi

    ln -s "${fromFilename}" "${toFilename}"
}

function createDir {
    local homeEnvRoot=("${1}")
    local destDirBase=("${2}")
    local d=("${3}")

    #echo "******* CreateDir: ${destDirBase} ${d}"

    local destDir="${destDirBase}${d#.}"
    echo "Creating ${destDir}"
    mkdir -p "${destDir}"
}

function installFile {
    local homeEnvRoot=("${1}")
    local destDirBase=("${2}")
    local f=("${3}")
    local filename="${f##*/}"
    local filePathname="${f#.}"
    local fromFilename="${homeEnvRoot}${filePathname}"
    local toFilename="${destDirBase}${filePathname}"

    #echo "******* filename=${filename}"
    #echo "******* filePathname=${filePathname}"
    #echo "******* fromFilename=${fromFilename}"
    #echo "******* toFilename=${toFilename}"

    # Check to see if the destination is already a link to the correct file
    if [ -h "${toFilename}" ] && [ "$(getLinkAbsoluteFilename ${toFilename})" = "${fromFilename}" ]; then
        # Already linked to the correct file, skip
        echo "File ${toFilename} already linked, skipping"
    else
        # Need to make the link
        toFileDir="${toFilename%/*}"
        fromFilenameRel=$(relativePath "${toFileDir}" "${fromFilename}")
        pushd "${toFileDir}" >&-
        backupLn "${fromFilenameRel}" "${toFilename}"
        pwd
        popd >&-
    fi
}

function installFiles {
    local homeEnvRoot=("${1}")
    local destDirBase=("${2}")

    if [[ ! -d ${homeEnvRoot} ]]; then
        echo "Skipping install files from ${homeEnvRoot}, directory does not exist"
        return
    fi

    echo "Installing from '${homeEnvRoot}' to '${destDirBase}'"
    pushd ${homeEnvRoot} >&-

    find . -type d -exec bash -c 'createDir "'${homeEnvRoot}'" "'${destDirBase}'" "$0"' {} ';'


    # Get list of all the files, ignoring VIM's temp files .swp, .swo, and .swn
    find . -type f -a ! -name ".*.sw[pon]" -exec bash -c 'installFile '"${homeEnvRoot}"' "'${destDirBase}'" "$0"' {} ';'

    popd >&-
}

export -f relativePath
export -f getLinkAbsoluteFilename
export -f backupFile
export -f backupLn
export -f createDir
export -f installFile

# Install files common to all OS envs
installFiles "${HOME_ENV_ROOT}" "${DEST_DIR_BASE}"

# Install files common to the specific OS type
installFiles "${HOME_ENV_ROOT}-${OS_TYPE}" "${DEST_DIR_BASE}"

# Install files for the specific OS name
installFiles "${HOME_ENV_ROOT}-${OS_NAME}" "${DEST_DIR_BASE}"

HISTFILE="${DEST_DIR_BASE}/.bash_history"
HISTALLFILE="${DEST_DIR_BASE}/.bash_history.all"

if [[ ! -f "${HISTFILE}" ]]; then
    echo "Creating ${HISTFILE}"
    printf "#0000000000\n \n" > ${HISTFILE}
fi

if [[ ! -f "${HISTALLFILE}" ]]; then
    echo "Creating ${HISTALLFILE}"
    printf "#0000000000\n \n" > ${HISTALLFILE}
fi

echo "Touching ${DEST_DIR_BASE}/.gitconfig-local"
touch "${DEST_DIR_BASE}/.gitconfig-local"

popd >&-
