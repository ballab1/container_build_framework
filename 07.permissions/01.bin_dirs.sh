#!/bin/bash

source "${TOOLS}/01.bashlib/lib.sh"

declare -r dirlist='/usr/local/bin /usr/bin /sbin'

for dir in ${dirlist}; do
    mkdir -p "$dir" && chmod -R 777 "$dir"
    declare -a files=( $( lib.getFiles "$dir" ) )
    [ ${#files[@]} -gt 0 ] && chmod 755 "$dir"/*
done
true
