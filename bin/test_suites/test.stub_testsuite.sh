#!/usr/bin/env bash_unit
#-----------------------------------------------------------------------------------------
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
# setup_suite()                                 __test_stub_testsuite_sh.mktemp()
# teardown_suite()                              __test_stub_testsuite_sh.mock_logger()
# setup()                                       export test_stub_testsuite_sh_LOG_file
# teardown()                                    export test_stub_testsuite_sh_UT_TEST_DIR
#                                               export test_stub_testsuite_sh_DEBUG
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

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.custom_support() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.die() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.file() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.main() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.nameSpace() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.setup() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.setup_suite() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.teardown() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.teardown_suite() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

#-----------------------------------------------------------------------------------------
# provide brief explanation of what test does
test.stub_testsuite.test_stub() {
    local expected=0
    local actual=0
#    assert_equals "$expected" "$actual"
    fail 'test not implemented'
}

##########################################################################################
#
# standard test framework routines
#
##########################################################################################

# load all the bash libraries, setup location for running test_suite,
setup_suite() {

    # create a temp directory for any files etc created by tests
    local -r tmpUserDir="${TMPDIR:-/tmp}/$USER"
    mkdir -p "$tmpUserDir"
    local temporaryDir=$(mktemp -d --tmpdir="$tmpUserDir" --suffix=test bash_unit_XXXXXXXXXXXXXXXXXX 2>/dev/null)
    mkdir -p "$temporaryDir"
    test_stub_testsuite_sh_UT_TEST_DIR="$temporaryDir"

    # point CBF & CRF to locations in tmp workspace.  Will load libs from there
    export CBF_LOCATION="$temporaryDir/tmp"            # set CBF_LOCATION for testing
    mkdir -p "$CBF_LOCATION"
    export CRF_LOCATION="$temporaryDir/usr/local/crf"  # set CRF_LOCATION for testing
    mkdir -p "$CRF_LOCATION"

    # pwd is location of test definition file.
    local cbf_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

    # copy CBF & CRF to workspace
    for dir in 'action.templates' 'cbf' 'project.template' ; do
        cp -r "${cbf_location}/${dir}" "$CBF_LOCATION"
    done

    # now init stuff for testing
    source "${CBF_LOCATION}/cbf/bin/init.libraries" #> /dev/null
}

# remove anything generated by test suite
teardown_suite() {

    # ensure directory is valid
    [ "$test_stub_testsuite_sh_UT_TEST_DIR" ] || return
    [ "$test_stub_testsuite_sh_UT_TEST_DIR" != '/' ] || return
    [ "$test_stub_testsuite_sh_UT_TEST_DIR" != '~' ] || return
    [ "$test_stub_testsuite_sh_UT_TEST_DIR" != "$( cd ~ && pwd )" ] || return
    [ "$test_stub_testsuite_sh_UT_TEST_DIR" != "$TMP" ] || return

    # clean up our junk
    rm -rf "$test_stub_testsuite_sh_UT_TEST_DIR"
}

# setup MOCK logger
setup() {
    [ "$test_stub_testsuite_sh_DEBUG" = 0 ] || printf "\e[94m%s\e[0m\n\n" 'Running setup'
    export LOG=__test_stub_testsuite_sh.mock_logger
    test_stub_testsuite_sh_LOG_file=$(__test_stub_testsuite_sh.mktemp)
    fake 'term.log' '__test_stub_testsuite_sh.mock_logger "$FAKE_PARAMS"'
    touch "$test_stub_testsuite_sh_LOG_file"
}

# flush the mock logger
teardown() {
    [ "$test_stub_testsuite_sh_DEBUG" = 0 ] || printf "\e[94m%s\e[0m\n\n" 'Running teardown'
    [ ! -e "$test_stub_testsuite_sh_LOG_file" ] || rm "$test_stub_testsuite_sh_LOG_file"

    [ ! -e "${CBF_LOCATION}/bashlibs.loaded" ] || rm "${CBF_LOCATION}/bashlibs.loaded"
    [ ! -e "${CBF_LOCATION}/environment.loaded " ] || rm "${CBF_LOCATION}/environment.loaded "
}

##########################################################################################
#
# custom support
#
##########################################################################################

# custom mktemp to create folder withing the temp storage location for this test
__test_stub_testsuite_sh.mktemp() {
    mktemp --tmpdir="$test_stub_testsuite_sh_UT_TEST_DIR" $* 2>/dev/null
}
export -f __test_stub_testsuite_sh.mktemp

# MOCK logger implementation
__test_stub_testsuite_sh.mock_logger() {
    printf "%s\n" "$*" >> "$test_stub_testsuite_sh_LOG_file"
}
export -f __test_stub_testsuite_sh.mock_logger

export test_stub_testsuite_sh_LOG_file
export test_stub_testsuite_sh_UT_TEST_DIR
export test_stub_testsuite_sh_DEBUG=0

##########################################################################################
