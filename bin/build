#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

declare NAME=${1:?'Input parameter "NAME" must be defined'} 
declare TZ="${2:-null}"

if [ -d 'container_build_framework' ]; then
    # load our libraries
    source "$( cd "$( dirname "${BASH_SOURCE[0]}" )/container_build_framework/bin" && pwd )/init.libraries"
    cbf.__init

    # build our container
    cbf.buildContainer "$NAME" "$TZ"
else
    echo "This script should only be run from a container build environment"
fi