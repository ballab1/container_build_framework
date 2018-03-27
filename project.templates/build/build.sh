CBF_VERSION=${CBF_VERSION:-2.0}
wget --no-check-certificate --quiet --output-document=- "https://github.com/ballab1/container_build_framework/archive/v${CBF_VERSION}.tar.gz" | tar -xz
source "container_build_framework-${CBF_VERSION}/bin/build.sh" "$@"