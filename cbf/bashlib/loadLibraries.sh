#!/bin/bash

# Use the Unofficial Bash Strict Mode
set -o errexit
set -o nounset
set -o pipefail
IFS=$'\n\t'


function __init.loader() {
#    __init.loadCBF

    # only load libraries from bashlib (not below). Sort to be deterministic
    local __libdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
    __libdir="$(readlink -f "$__libdir")"

    local dir __lib
    local -a __libs

    # locate our bashlib directory
    for dir in "$__libdir" "${__libdir}/bashlib" /usr/local/crf/bashlib; do
        [ -d "$dir" ] || continue
        mapfile -t __libs < <(find "$dir" -maxdepth 1 -mindepth 1 -name '*.bashlib' -not -name 'appenv.bashlib' | sort)
        [ "${#__libs[*]}" -eq 0 ] || break
    done

    if [ "${#__libs[*]}" -gt 0 ]; then
        # load the bashlib files in this directory
        echo -en "    loading project libraries from $__libdir: \e[35m"
        [[ "${DEBUG:-}" || "${DEBUG_TRACE:-0}" -gt 0 ]] && echo
        for __lib in "${__libs[@]}"; do
            if [[ "${DEBUG:-}" || "${DEBUG_TRACE:-0}" -gt 0 ]]; then
                echo "        $__lib"
            else
                echo -n " $(basename "$__lib")"
            fi
            source "$__lib"
        done
        echo -e '\e[0m'
    fi
    [ ! -e "${__libdir}/init.cache" ] || source "${__libdir}/init.cache"
}

if [[ "${DEBUG:-}" || "${DEBUG_TRACE:-0}" -gt 0 ]]; then
    __init.loader >&2
else
    # TODO: instead of op to /dev/null, op to file; check for error and cat file if true; rm file.  (cannot use $(...) bcause it hides lib functions)
    __init.loader &> /dev/null
fi
