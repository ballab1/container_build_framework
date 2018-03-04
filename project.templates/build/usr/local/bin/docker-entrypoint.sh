#!/bin/bash

declare -r config_entry='newcontainer-setup' 
declare -r tools=/usr/local/crf
source "${tools}/init.runtime"
docker.setExports


if [[ "$1" = 'newcontainer' ]]; then
    # this is the primary (default) codepath invoked by the Dockerfile
    printf "\e[32m>>>>>>>> entering \e[33m'%s'\e[0m\n" "$1"
    [ "$( which sudo )" ] && sudo -E "$0" "$config_entry"
    [ ! -e "${tools}/run.sh" ] && trap.die 'No run.sh detected'
    exec "${tools}/run.sh"

elif [[ "$1" = "$config_entry" && "$(id -u)" -eq 0 ]]; then
    # this codepath is invoked (from above) to perpare the runtime environment. User is 'root' so chmod & chown succeed
    printf "\e[32m>>>>>>>> entering \e[33m'%s'\e[0m\n" "$*"
    docker.prepareEnvironment

elif [ $# -gt 0 ]; then
    # this codepath is invoked when a user invokes the container using 'docker run'
    printf "\e[32m>>>>>>>> entering \e[33m'%s'\e[0m\n" 'custom'
    shift
    exec $@
fi 
printf "\e[32m<<<<<<<< returning from \e[33m'%s'\e[0m\n" "$*" 
