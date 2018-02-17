#!/bin/bash
#############################################################################
#
#   support.sh
#
#############################################################################

declare -A support


#############################################################################
function support.installBatsModules()
{
    local -r test_dir=${1:?"must pass parameter 'test_dir' to 'function ${FUNCNAME[0]}()'"} 
    
    if [ ${#support[*]} -eq 0 ]; then
        # configure where our test framework comes from, adn in which dir it resides
        support['BATS_MODULES_REPO']="https://github.com/ballab1/bats-modules.git"
        support['BATS_DIR']="$( cd "$test_dir" && pwd )"
        support['BATS']="${support['BATS_DIR']}/bats/bin/bats"

        # download the test framework
        git clone -depth 1 --recurse "${support['BATS_MODULES_REPO']}" "${support['BATS_DIR']}"

        # load the framework
        for dir in ( 'bats-assert' 'bats-support' 'bats-files' ); do
            for file in $(find "${support['BATS_DIR']}/$dir" -name '*.bash'); do
                source "$file"
            done
        done
    fi
}

#############################################################################
function support.runTests()
{
    local -r tests_to_run=${1:?"must pass parameter 'tests_to_run' to 'function ${FUNCNAME[0]}()'"} 

    if [ ${#support[*]} -eq 0 ]; then
        local temporaryDir=$(mktemp -d --tmpdir="${TMPDIR:-/tmp}/$USER" --suffix=test bats_XXXXXXXXXXXXXXXXXX 2>/dev/null) 
        support.installBatsModules "temporaryDir"
    fi
    "${support['BATS']}" "$( cd "$tests_to_run" && pwd )"
}

#############################################################################
