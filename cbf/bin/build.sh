#!/bin/bash

# Use the Unofficial Bash Strict Mode
set -o errexit
set -o nounset
set -o pipefail
IFS=$'\n\t'

declare NAME=${1:?'Input parameter "NAME" must be defined'}
declare -x DEBUG_TRACE=${2:-0}
declare -x TZ="${3:-}"

function die() {
    echo "$1"
    exit 1
}

[ "$(pwd)" = '/tmp' ] || die "This script should only be run from a container build environment"


# load our libraries
[ ! -e /tmp/bashlibs.loaded ] || rm /tmp/bashlibs.loaded ||  die "Failed to remove /tmp/bashlibs.loaded"
source "$(readlink -f "$( dirname "${BASH_SOURCE[0]}" )")/init.libraries"

# build our container
timer.measureCmd "$NAME" 'cbf.buildContainer' "$NAME" "$DEBUG_TRACE" "$TZ"
rm "$(crf.propertiesFile)"
rm "$(cbf.propertiesFile)"
echo ''
echo ''
