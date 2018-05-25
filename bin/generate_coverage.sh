#!/bin/bash

declare -r base="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
[ -d "${base}/out" ] && sudo rm -rf "${base}/out"
mkdir -p "${base}/out"


echo "Generating Coverage information. This will take a few seconds."
# generate coverage  (refs follow)
#   https://hub.docker.com/r/ragnaroek/kcov/
#   https://simonkagstrom.github.io/kcov/
#   https://simonkagstrom.livejournal.com/50380.html
docker run --security-opt seccomp=unconfined \
           -v "${base}":/source \
           afeoscyc-mw.cec.lab.emc.com/kcov:v33 \
           --exclude-pattern "/tmp,/source/unit-tests" \
           /source/out \
           /source/unit-tests/run_unit_tests.sh > "${base}/out/coverage.log" 2>&1

# make sure we can access the files (since container runs as root)           
sudo chown -R "$UID" "${base}/out"

# make result reporting context aware  (dev/JENKINS)
declare results_base="$base"
[ "${BUILD_URL:-}" ] && results_base="${BUILD_URL}/archive"
echo "Coverage information: ${results_base}/out/run_unit_tests.sh/index.html"
