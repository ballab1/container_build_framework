#!/bin/bash

function customizations.custom_folders()
{
    local -r tools=$1
    local -r dirs=$2
    
    for dir in ${dirs} ; do
        [ -d "${tools}/${dir}" ] && cp -r "${tools}/${dir}/"* "/${dir}/"
    done
    true
}

customizations.custom_folders /tmp 'etc usr opt var'
