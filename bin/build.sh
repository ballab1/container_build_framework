#!/bin/bash

set -o errexit
set -o nounset 

declare NAME=${1:?'Input parameter "NAME" must be defined'} 
declare TZ="${2:-null}"

if [ "$(pwd)" != '/tmp' ]; then
    echo "This script should only be run from a container build environment"
    exit 1
fi

# load our libraries
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/init.libraries"

# build our container
timer.measureCmd "$NAME" 'cbf.buildContainer' "$NAME" "$TZ"
echo ''
echo ''
