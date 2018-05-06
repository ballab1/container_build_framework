#!/bin/bash
#############################################################################
#
#   stub_testsuite.sh
#
#############################################################################

declare -r SPLITTER='#-----------------------------------------------------------------------------------------'

#----------------------------------------------------------------------------
function stub_testsuite.die()
{
    local status=$?
    [[ $status -ne 0 ]] || status=255

    printf "\n\e31[mFATAL ERROR: %s\e[0m\n" "$*" >&2
    exit $status
}

#----------------------------------------------------------------------------
function stub_testsuite.file()
{
    local -r file_under_test=${1:?"Input parameter 'file_under_test' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local -r test_file=${2:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    
    printf "\nGenerating test suite file: %s\n" "${test_file}"
    
    local namespace="$( stub_testsuite.nameSpace "$test_file" )"

cat << EOF > "$test_file"
#!/usr/bin/env bash_unit
${SPLITTER}
#
#  test suite for https://github.com/ballab1/container_build_framework.git
#
#  You may need to change the behavior of some commands to create conditions for your code under test
#  to behave as expected. The *fake* function may help you to do that, see documentation.
#
# Organization of this test suite
# ===============================
# test methods
# standard test framework routines
# custom support provided within this suite
# 
#
# standard test framework routines              custom support provided within this suite
# --------------------------------              -----------------------------------------
# setup_suite()                                 __${namespace}.mktemp()
# teardown_suite()                              __${namespace}.mock_logger()
# setup()                                       export ${namespace}_LOG_file 
# teardown()                                    export ${namespace}_UT_TEST_DIR
#                                               export ${namespace}_DEBUG
#                                              
#
# bash_unit supports several shell oriented assertion functions.
# --------------------------------------------------------------
# fail()
# assert()
# assert_fail()
# assert_status_code()
# assert_equals()
# assert_not_equals()
# fake()
#    Using stdin
#    Using a function
#    fake parameters
#
##########################################################################################
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.custom_support()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local namespace="$( stub_testsuite.nameSpace "$test_file" )"
    
    printf "  adding: custom support\n"
    printf "    __${namespace}.mktemp\n"
    printf "    __${namespace}.mock_logger\n"
    printf "    exports\n"
cat << EOF >> "$test_file"

##########################################################################################
#
# custom support
#
##########################################################################################

# custom mktemp to create folder withing the temp storage location for this test
__${namespace}.mktemp() {
    mktemp --tmpdir="\$${namespace}_UT_TEST_DIR" \$* 2>/dev/null
}
export -f __${namespace}.mktemp

# MOCK logger implementation
__${namespace}.mock_logger() {
    printf "%s\n" "\$FAKE_PARAMS" >> "\${${namespace}_LOG_file}"
}
export -f __${namespace}.mock_logger

export ${namespace}_LOG_file 
export ${namespace}_UT_TEST_DIR
export ${namespace}_DEBUG=0

##########################################################################################
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.setup()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local namespace="$( stub_testsuite.nameSpace "$test_file" )"
    
    printf "  adding: setup\n"
cat << EOF >> "$test_file"

# setup MOCK logger
setup() {
    [ "\$${namespace}_DEBUG" = 0 ] || printf "\e[94m%s\e[0m\n\n" 'Running setup'
    export LOG=__${namespace}.mock_logger
    ${namespace}_LOG_file=\$(__${namespace}.mktemp)
    fake 'term.log' '__${namespace}.mock_logger \$*'
    touch "\$${namespace}_LOG_file" 
}
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.setup_suite()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local namespace="$( stub_testsuite.nameSpace "$test_file" )"
    
    printf "  adding: setup_suite\n"
cat << EOF >> "$test_file"

##########################################################################################
#
# standard test framework routines
#
##########################################################################################

# load all the bash libraries, setup location for running test_suite, 
setup_suite() {

    # create a temp directory for any files etc created by tests
    local -r tmpUserDir="\${TMPDIR:-/tmp}/\$USER"
    mkdir -p "\$tmpUserDir"
    local temporaryDir=\$(mktemp -d --tmpdir="\$tmpUserDir" --suffix=test bash_unit_XXXXXXXXXXXXXXXXXX 2>/dev/null)
    mkdir -p "\$temporaryDir"
    ${namespace}_UT_TEST_DIR="\$temporaryDir" 

    # point CBF & CRF to locations in tmp workspace.  Will load libs from there
    export CBF_LOCATION="\$temporaryDir/tmp"            # set CBF_LOCATION for testing
    mkdir -p "\$CBF_LOCATION"
    export CRF_LOCATION="\$temporaryDir/usr/local/crf"  # set CRF_LOCATION for testing
    mkdir -p "\$CRF_LOCATION"

    # pwd is location of test definition file.
    local cbf_location="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )/../.." && pwd )"

    # copy CBF & CRF to workspace
    for dir in 'action.templates' 'bin' 'cbf' 'crf' 'project.templates' ; do
        cp -r "\${cbf_location}/\${dir}" "\$CBF_LOCATION"
    done
    cp -r "\${cbf_location}/crf"/* "\$CRF_LOCATION"
    
    # now init stuff for testing
    source "\${CBF_LOCATION}/bin/init.libraries" #> /dev/null
} 
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.teardown()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local namespace="$( stub_testsuite.nameSpace "$test_file" )"
    
    printf "  adding: teardown\n"
cat << EOF >> "$test_file"

# flush the mock logger
teardown() {
    [ "\$${namespace}_DEBUG" = 0 ] || printf "\e[94m%s\e[0m\n\n" 'Running teardown'
    [ ! -e "\$${namespace}_LOG_file" ] || rm "\$${namespace}_LOG_file"

    [ ! -e "\${CBF_LOCATION}/bashlibs.loaded" ] || rm "\${CBF_LOCATION}/bashlibs.loaded"
    [ ! -e "\${CBF_LOCATION}/environment.loaded " ] || rm "\${CBF_LOCATION}/environment.loaded "
}
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.teardown_suite()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local namespace="$( stub_testsuite.nameSpace "$test_file" )"
    
    printf "  adding: teardownsuite\n"
cat << EOF >> "$test_file"

# remove anything generated by test suite
teardown_suite() {

    # ensure directory is valid
    [ "\$${namespace}_UT_TEST_DIR" ] || return
    [ "\$${namespace}_UT_TEST_DIR" != '/' ] || return
    [ "\$${namespace}_UT_TEST_DIR" != '~' ] || return
    [ "\$${namespace}_UT_TEST_DIR" != "\$( cd ~ && pwd )" ] || return
    [ "\$${namespace}_UT_TEST_DIR" != "\$TMP" ] || return

    # clean up our junk
    rm -rf "\$${namespace}_UT_TEST_DIR"
}
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.test_stub()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local -r function_name=${2:?"Input parameter 'function_name' must be passed to 'function ${FUNCNAME[0]}()'"} 
    
    printf "    adding test stub for: %s\n" "$function_name"
cat << EOF >> "$test_file"

${SPLITTER}
# provide brief explanation of what test does
test.${function_name}() {
    local expected=0
    local actual=0
#    assert_equals "\$expected" "\$actual" 
    fail 'test not implemented'
}
EOF
}

#----------------------------------------------------------------------------
function stub_testsuite.main()
{
    local -r fut=${1:?"Input parameter 'fut' must be passed to 'function ${FUNCNAME[0]}()'"} 
    local -r test_dir=${2:?"Input parameter 'test_dir' must be passed to 'function ${FUNCNAME[0]}()'"} 

    [ -e "$fut" ] || stub_testsuite.die "Test file does not exist"

    # fully qualified name of file_under_test
    local -r file_under_test="$( cd "$( dirname "$fut" )" && pwd )/$( basename "$fut" )"

    # test file in test directory. name:  remove extension and prefix with 'test.'
    local -r test_file="${test_dir}/test.$( basename "$fut" )"


    printf "\nFile under test:            ${file_under_test}"

    stub_testsuite.file "$file_under_test" "$test_file"

    local -i test_count=0
    for function_name in $(grep -E '^function\s+.*\s*\(\)\s*\}?$' "$file_under_test" | sed -e 's|function ||' -e 's|(||' -e 's|)||' -e 's|{||' -e 's| ||' | sort)
    do
        stub_testsuite.test_stub "$test_file" "$function_name"
        (( test_count++ ))
    done
    
    stub_testsuite.setup_suite "$test_file"
    stub_testsuite.teardown_suite "$test_file"
    stub_testsuite.setup "$test_file"
    stub_testsuite.teardown "$test_file"
    stub_testsuite.custom_support "$test_file"

    printf "\n%d tests generated\n" ${test_count}
}

#----------------------------------------------------------------------------
function stub_testsuite.nameSpace()
{
    local -r test_file=${1:?"Input parameter 'test_file' must be passed to 'function ${FUNCNAME[0]}()'"} 

    echo "$( basename "${test_file//./_}" )"
}

#----------------------------------------------------------------------------

declare -r TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/test_suites" && pwd )"
stub_testsuite.main "${1?"Input parameter 'FUT' must be passed to '${BASH_SOURCE[0]}'"}" "$TEST_DIR" 