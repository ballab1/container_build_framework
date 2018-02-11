#!/bin/bash -x

function permissions.set_bindirs()
{
    local -r dirlist=$1
    
    for dir in ${dirlist}; do
        mkdir -p "$dir" && chmod -R 777 "$dir"
        local -a files=( $( ls "$dir"/* 2> /dev/null ) )
        [ ${#files[@]} -gt 0 ] && chmod 755 "${files[*]}"
    done
}

permissions.set_bindirs '/usr/local/bin /usr/bin'