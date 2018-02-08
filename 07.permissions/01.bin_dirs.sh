#!/bin/bash

function permissions.set_bindirs()
{
    local -r dirlist=$1
    
    for dir in ${dirlist}; do
        mkdir -p ${dir} && chmod -R 777 ${dir}
    done
}

permissions.set_bindirs '/usr/local/bin /usr/bin'