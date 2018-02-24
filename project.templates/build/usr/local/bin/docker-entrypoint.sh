#!/bin/bash

declare -r config_entry='newcontainer-setup' 
declare -r tools=/usr/local/bin
source "${tools}/docker.helper"
docker.setExports


if [[ "$1" = 'newcontainer' ]]; then
    # this is the primary (default) codepath invoked by the Dockerfile
    printf "\e[32m>>>>>>>> entering \e[33m'%s'\e[0m\n" "$1"
    sudo --preserve-env "$0" "$config_entry"
    /sbin/tini -s -v -- "${tools}/run.sh"

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
