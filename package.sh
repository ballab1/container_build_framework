#!/bin/bash
#############################################################################
#
#   package.sh
#
#############################################################################
function package.getPackages()
{
    local -r dir=${1:?'Input parameter "dir" must be defined'}
    local -r tools="$( lib.getBase )"

    while read -r pkg; do
        package.install "$pkg"
    done < <(find "${tools}/${dir}" -maxdepth 1 -type f ! -name '.*' | sort)
}

#############################################################################
function package.install()
{
    local -r pkg=${1:?'Input parameter "pkg" must be defined'}
    
    IFS=$'\r\n'
    local -a contents=( $(< "$pkg") )
    $LOG "Installing ${pkg} - ${#contents[*]} lines read${LF}" 'task'

    if [ "${contents[1]:0:5}" = 'cmd: ' ]; then
        local comment="${contents[0]}"
        local cmd="${contents[1]:5}"
        contents=( ${contents[@]:2} )
        $LOG "..${comment}:  '${cmd} ${contents}'${LF}" 'info'
        eval $cmd $contents || $LOG "..issue while installing ${contents}${LF}" 'warn'
    else
        $LOG "..package file not formatted correctly ${pkg}${LF}" 'warn'
    fi
}

#############################################################################
function package.installTimezone()
{
    local -r tz=${1:?'Input parameter "tz" must be defined'}
    
    apk add --no-cache tzdata
    echo "$tz" > /etc/TZ
    cp "/usr/share/zoneinfo/$tz" /etc/timezone
    cp "/usr/share/zoneinfo/$tz" /etc/localtime
}
