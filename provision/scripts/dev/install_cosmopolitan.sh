#! /bin/bash
set -e

requires \
    curl \
    unzip
main() {
    local VERSION="${1:-"3.3"}"
    curl "https://cosmo.zip/pub/cosmocc/cosmocc-${VERSION}.zip" --output /tmp/cosmocc.zip
    unzip /tmp/cosmocc.zip -d /cosmopolitan
    ln -s /cosmopolitan/bin/cosmocc /usr/local/bin/cosmocc
}
main "$@"