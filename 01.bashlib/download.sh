#!/bin/bash

#############################################################################
#
#   download.sh
#
#############################################################################
function download.getFile()
{
    local -r file=${1:?'Input parameter "file" must be defined'}

    # load download definition
    source "$file"
    local name="$( basename "$file" )"
    $LOG "Downloading from definition:  ${name}${LF}" 'task'

    # strip path & prefix from file to get name
    name="${name//[0-9]/}"
    name="${name#.}"

    # derefernce our params
    local -A params=( ['file']="$( lib.indirectReference "$name" 'file' )" \
                      ['url']="$( lib.indirectReference "$name" 'url' )" \
                      ['sha256']="$( lib.indirectReference "$name" 'sha256' )" \
                    )
    $LOG "....file:  ${params['file']}${LF}" 'info'
    $LOG ".....url:  ${params['url']}${LF}" 'info'
    $LOG "..sha256:  ${params['sha256']}${LF}" 'info'

    local -i attempt
    for attempt in {0..3}; do
        [ $attempt -eq 3 ] && exit 1
        wget -O "${params['file']}" --no-check-certificate "${params['url']}"
        [ $? -ne 0 ] && continue
        local result=$(echo "${params['sha256']}  ${params['file']}" | sha256sum -cw 2>&1)
        $LOG "${result}${LF}" 'info'
        if [[ "$result" == *'FAILED'* ]]; then
            $LOG "..Incorrect checksum for ${params['file']}${LF}" 'warn'
            $LOG "    actual:   $( sha256sum "${params['file']}" | awk '{ print $1 }')${LF}" 'warn'
            exit 1
        fi
        if [[ "$result" == *' WARNING: '* ]]; then
            $LOG "..failed to successfully download ${params['file']}. Retrying....${LF}" 'info'
            continue
        fi
        return 0
    done
    exit 1
}


#############################################################################
function download.getPackages()
{
    local -a files=${1:?'Input parameter "files" must be defined'}

    for file in ${files} ; do
        eval download.getFile "$file" || $LOG ">>>>> issue while downloading $( basename "$file" ) <<<<<${LF}" 'warn'
    done
}
