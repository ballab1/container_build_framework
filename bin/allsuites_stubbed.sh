#!/bin/bash
#############################################################################
#
#   generate_tests.sh
#
#############################################################################

declare -r wsdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

cd "$wsdir"
find bin cbf/bin cbf/bashlib -maxdepth 1 -mindepth 1 -type f ! -name '.*' -exec "${wsdir}/bin/stub_testsuite.sh" '{}' -gen \;
