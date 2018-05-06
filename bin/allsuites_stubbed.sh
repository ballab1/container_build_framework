#!/bin/bash
#############################################################################
#
#   generate_tests.sh
#
#############################################################################

declare -r wsdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

cd "$wsdir"
for file in $(find cbf bin crf/bin crf/bashlib -maxdepth 1 -mindepth 1 -type f ! -name '.*'); do
    "${wsdir}/bin/stub_testsuite.sh" "$file"
done
