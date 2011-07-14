#!/bin/bash

mkdir homeEnv
pushd homeEnv
curl -k -L https://github.com/mcompton13/homeEnv/tarball/master | tar --strip-components=1 -zxv
source installenv.sh
popd
