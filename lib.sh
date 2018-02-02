#!/bin/bash
#############################################################################
#
#   lib.sh
#
#############################################################################
function lib.buildContainer()
{
    local -r name=${1:?'Input parameter "name" must be defined'}
    local -r timezone=${2:-null}
    export TOOLS=$( lib.getBase )
    
    term.header "$name"
    lib.runScripts '02.packages' 'Install OS Support'
    [ "$timezone" != null ] && package.installTimezone "$timezone"
    uidgid.check '03.users_groups' 'Verify users and groups'
    download.getPackages '04.downloads'
    lib.runScripts '05.applications' 'Install applications'
    lib.runScripts '06.customizations' 'Add configuration and customizations'
    lib.runScripts '07.permissions' 'Make sure that ownership & permissions are correct'
    lib.runScripts '08.cleanup' 'Clean up'
}

#############################################################################
function lib.getBase()
{
    printf "%s" "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"   
}

#############################################################################
function lib.indirectReference()
{
    local -r hash=${1:?'Input parameter "hash" must be defined'}
    local -r key=${2:?'Input parameter "key" must be defined'}
    set +o nounset
    local -r default="$3"

    local val=$( eval "echo \${$hash[$key]}" )
    [ -z "$val" ] && val="$default"
    echo "$val"
    set -o nounset
}

#############################################################################
function lib.runScripts()
{
    local -r dir=${1:?'Input parameter "dir" must be defined'}
    local -r notice=${2:-' '}
    local -r tools="$( lib.getBase )"

    IFS=$'\r\n'
    local files="$(find "${tools}/${dir}" -maxdepth 1 -type f ! -name '.*' | sort)"
    if [ "$files" ]; then
        [ "$notice" != ' ' ] && $LOG "${notice}${LF}" 'task'
        for file in ${files} ; do
            chmod 755 "$file"
            $LOG "..executing ${file}${LF}" 'info'
            eval "$file" || $LOG ">>>>> issue while executing $( basename "$file" ) <<<<<${LF}" 'warn'
        done
    fi
}

#############################################################################
