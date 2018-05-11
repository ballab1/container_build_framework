#!/bin/bash
#############################################################################
#
#   bash_unit_test.sh
#
#############################################################################

declare -rA BASH_UNIT=(
    ['version']='v1.6.1'
    ['file']="bash_unit.tar.gz"
    ['url']="https://github.com/pgrange/bash_unit/archive/v1.6.1.tar.gz"
    ['sha256']='596c2bcbcebcc5611e3f2e1458b0f4be1adad8f91498b20e97c9f7634416950f'
)

declare -A test=()

# tests are maintained in the 'test_suites' folder in directory this script is in
declare -r DIR_OF_TESTS_TO_RUN="$( cd "$( dirname "${BASH_SOURCE[0]}" )/test_suites" && pwd )"


#############################################################################
function test.downloadFramework()
{
    local -r download_dir=${1:?"must pass parameter 'download_dir' to 'function ${FUNCNAME[0]}()'"} 

    if [[ -n "${download_dir}" && "${download_dir}" != '/' ]]; then
        pushd "$download_dir"

        echo "Downloading unit_test framework:"
        echo "....file:  ${BASH_UNIT['file']}"
        echo ".....url:  ${BASH_UNIT['url']}"
        echo "..sha256:  ${BASH_UNIT['sha256']}"

        local -i attempt
        for attempt in {0..3}; do
            [ $attempt -lt 3 ] || break
            [ ! -e "${BASH_UNIT['file']}" ] || rm "${BASH_UNIT['file']}"
            wget -O "${BASH_UNIT['file']}" --no-check-certificate "${BASH_UNIT['url']}" > /dev/null 2>&1
            [ $? -eq 0 ] || continue
            local result=$(echo "${BASH_UNIT['sha256']}  ${BASH_UNIT['file']}" | sha256sum -cw 2>&1)
            echo "${result}"
            if [[ "$result" == *'FAILED'* ]]; then
                echo "..Incorrect checksum for ${BASH_UNIT['file']}"
                echo "    actual:   $( sha256sum "${BASH_UNIT['file']}" | awk '{ print $1 }')"
                continue
            fi
            if [[ "$result" == *' WARNING: '* ]]; then
                echo "..failed to successfully download ${BASH_UNIT['file']}. Retrying...."
                continue
            fi

            # unpack the unit test framework in our tmp folder, and use to run tests
            tar -xvf "${BASH_UNIT['file']}" #> /dev/null 2>&1
            local framework="${download_dir}/bash_unit-${BASH_UNIT['version']#v}/bash_unit"
            echo "framework:  $framework"
            [ -e "$framework" ] || break
            chmod 755 "$framework"
            test['BASH_UNIT']="$framework"
            popd
            return 0
        done
        # fail if downloaded was unsuccessful
        popd
        rm -rf "$download_dir"
    fi
    echo "FATAL ERROR: there was an issue when downloading the unit_test framework from: ${BASH_UNIT['url']}"
    return 1
} 

#############################################################################
function test.processArgs()
{
    local -a args=( $@ )

    if [ ${#args[*]} -eq 0 ]; then
        args=( test* )
    
    else
        for (( i=0; i<${#args[@]}; i++ )); do
            local f="${args[i]}"

            # skip if nothing to do
            [ -e "$f" ] && continue
         
            # move pattern definitions to beginning of args
            if [ "$f" = '-p' ]; then
                (( i++ ))
                local pattern="${args[i]}"
                for (( j=i; j>1; j-- )); do
                    let k=( j - 2 )
                    args[j]="${args[k]}"
                done
                args[0]='-p'
                args[1]="${pattern}"
                continue
            fi

            # add prefix if ommitted
            if [ -e "test.$f" ]; then
                args[i]="test.${args[i]}"
                continue
            fi

            # add suffix if ommitted
            if [ -e "${f}.bashlib" ]; then
                args[i]="${args[i]}.bashlib"
                continue
            fi

            # add prefix & suffix if ommitted
            if [ -e "test.${f}.bashlib" ]; then
                args[i]="test.${args[i]}.bashlib"
                continue
            fi
        done
    fi
    printf "%s\n" "${args[@]}"
} 

#############################################################################
function test.main()
{
    cd "$DIR_OF_TESTS_TO_RUN"

    local -a args=( $(test.processArgs "$@") )
printf "%s\n" "${args[@]}"

    # configure where our test framework comes from, and in which dir it resides
    if [ ${#test[*]} -eq 0 ]; then
        local -r test_dir="${BASH_UNIT_ROOT:-$(test.tmpDir)}" 
        test['BASH_UNIT_DIR']="$( cd "$test_dir" && pwd )"
    
        # run tests
        if [ "$BASH_UNIT_ROOT" = "${test['BASH_UNIT_DIR']}" ]; then
            test['BASH_UNIT']="${test['BASH_UNIT_DIR']}/bash_unit"
            "${test['BASH_UNIT']}" -f tap "${args[@]}"

        # download the test framework if needed
        elif test.downloadFramework "${test['BASH_UNIT_DIR']}" ; then

            "${test['BASH_UNIT']}" -f tap "${args[@]}"
            # remove framework that was downloaded
            rm -rf "${test['BASH_UNIT_DIR']}"
        fi
    fi
}

#############################################################################
function test.tmpDir()
{
    local -r tmpUserDir="${TMPDIR:-/tmp}/$USER"
    mkdir -p "$tmpUserDir"
    local temporaryDir=$(mktemp -d --tmpdir="$tmpUserDir" --suffix='.test' bash_unit_XXXXXXXXXXXXXXXXXX 2>/dev/null)
    mkdir -p "$temporaryDir"
    echo "$temporaryDir"
}

#############################################################################
#
#  *bash_unit* changes the current working directory to the one of the running test file.
#   If you need to access files from your test code, for instance the script under test,
#   use path relative to the test file.
#
#  You may need to change the behavior of some commands to create conditions for your code under test
#  to behave as expected. The *fake* function may help you to do that, see documentation.
#
# bash_unit supports several shell oriented assertion functions.
# --------------------------------------------------------------
# fail
# assert
# assert_fail
# assert_status_code
# assert_equals
# assert_not_equals
# fake function
#    Using stdin
#    Using a function
#    fake parameters
#
#############################################################################

test.main "$@"
