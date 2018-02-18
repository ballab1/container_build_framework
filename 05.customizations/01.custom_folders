#!/bin/bash

declare -r tools=/tmp
declare -r dirs='bin etc home lib lib64 media mnt opt root sbin usr var'

for dir in ${dirs} ; do
    [ -d "${tools}/${dir}" ] && cp -r "${tools}/${dir}/"* "/${dir}/"
done

true
