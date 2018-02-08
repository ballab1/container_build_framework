#!/bin/bash
#############################################################################
#
#   uidgid.sh
#
#############################################################################

function uidgid.check()
{
    local -r dir=${1:?'Input parameter "dir" must be defined'}
    local -r notice=${2:-' '}

    IFS=$'\r\n'
    local files="$(ls -1 "${TOOLS}/${dir}"/* 2>/dev/null | sort)"
    if [ "$files" ]; then
        [ "$notice" != ' ' ] && $LOG "${notice}${LF}" 'task'
        for file in ${files} ; do
            chmod 755 "$file"
            $LOG "..executing ${file}${LF}" 'info'
            eval uidgid.createUserAndGroup "$file" || $LOG "..*** issue while executing $( basename "$file" ) ***${LF}" 'warn'
        done
    fi
}

#############################################################################
function uidgid.createUserAndGroup()
{
    source "$file"

    #strip path & prefix from file to get name
    local name="$( basename "$file" )"
    name="${name//[0-9]/}"
    name="${name#.}"

    local user="$( lib.indirectReference $name 'user' )"
    local uid="$( lib.indirectReference $name 'uid' )"
    local group="$( lib.indirectReference $name 'group' )"
    local gid="$( lib.indirectReference $name 'gid' )"
    local homedir="$( lib.indirectReference $name 'home' )"
    local shell="$( lib.indirectReference $name 'shell' )"

    
    local wanted=$( printf '%s:%s' $group $gid )
    local nameMatch=$( getent group "${group}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    local idMatch=$( getent group "${gid}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    $LOG "INFO: group/gid (${wanted}):  is currently (${nameMatch})/(${idMatch})${LF}" 'info'

    if [[ $wanted != $nameMatch  ||  $wanted != $idMatch ]]; then
        $LOG "create group:  ${group}${LF}" 'info'
        [[ "$nameMatch"  &&  $wanted != $nameMatch ]] && groupdel "$( getent group ${group} | awk -F ':' '{ print $1 }' )"
        [[ "$idMatch"    &&  $wanted != $idMatch ]]   && groupdel "$( getent group ${gid} | awk -F ':' '{ print $1 }' )"
        /usr/sbin/groupadd --gid "${gid}" "${group}"
    fi

    
    wanted=$( printf '%s:%s' $user $uid )
    nameMatch=$( getent passwd "${user}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    idMatch=$( getent passwd "${uid}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    $LOG "INFO: user/uid (${wanted}):  is currently (${nameMatch})/(${idMatch})${LF}" 'info'
    
    if [[ $wanted != $nameMatch  ||  $wanted != $idMatch ]]; then
        $LOG "create user: ${user}${LF}" 'info'
        [[ "$nameMatch"  &&  $wanted != $nameMatch ]] && userdel "$( getent passwd ${user} | awk -F ':' '{ print $1 }' )"
        [[ "$idMatch"    &&  $wanted != $idMatch ]]   && userdel "$( getent passwd ${uid} | awk -F ':' '{ print $1 }' )"

        if [ "$homedir" ]; then
            [ -d "$homedir" ] || mkdir -p "$homedir"
            /usr/sbin/useradd --home-dir "$homedir" --uid "${uid}" --gid "${gid}" --no-create-home --shell "${shell}" "${user}"
        else
            /usr/sbin/useradd --no-create-home --uid "${uid}" --gid "${gid}" --no-create-home --shell "${shell}" "${user}"
        fi
    fi
} 
