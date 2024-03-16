#! /bin/bash
set -e

requires \
    binfmt-support \
    curl \
    unzip
main() {
    local VERSION="${1:-"3.3"}"
    #
    # Install APE loader
    #
    update-binfmts --enable
    sh -c "echo ':APE:M::MZqFpD::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
    sh -c "echo ':APE-jart:M::jartsr::/usr/bin/ape:' >/proc/sys/fs/binfmt_misc/register"
    #
    # Install Cosmopolitan
    #
    curl "https://cosmo.zip/pub/cosmocc/cosmocc-${VERSION}.zip" --output /tmp/cosmocc.zip
    unzip /tmp/cosmocc.zip -d /cosmopolitan
    ln -s /cosmopolitan/bin/mktemper /usr/local/bin/mktemper
    ln -s /cosmopolitan/bin/cosmocc /usr/local/bin/cosmocc
}
main "$@"