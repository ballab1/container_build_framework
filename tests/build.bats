#!/usr/bin/env bats

# Special variables
# There are several global variables you can use to introspect on Bats tests:
#
# $BATS_TEST_FILENAME is the fully expanded path to the Bats test file.
# $BATS_TEST_DIRNAME is the directory in which the Bats test file is located.
# $BATS_TEST_NAMES is an array of function names for each test case.
# $BATS_TEST_NAME is the name of the function containing the current test case.
# $BATS_TEST_DESCRIPTION is the description of the current test case.
# $BATS_TEST_NUMBER is the (1-based) index of the current test case in the test file.
# $BATS_TMPDIR is the location to a directory that may be used to store temporary files.
#
# Any output that is printed outside of @test, setup or teardown functions must be redirected to stderr (>&2).
# Otherwise, the output may cause Bats to fail by polluting the TAP stream on stdout.


#Tests for bin/build
export LOG=test_log

function setup() {
  source "$BATS_TEST_DIRNAME/../lib/download.bashlib"

  rep_log=.
  script_name=test_log
}

@test "build" {
  run ../bin/build
}
