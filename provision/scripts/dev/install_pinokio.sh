#! /bin/bash
set -e

requires \
    xvfb
main() {
    #
    # Install dependencies
    #
    apt-get update
    apt-get install --no-install-recommends --yes \
        libasound2
    #
    # Install Pinokio browser
    # (Note: Need to forwaard ports 42000 & 7860)
    #
    # shellcheck disable=SC2155
    local PWD="$(pwd)"
    local FILENAME='pinokio.deb'
    local VERSION="${1:-"1.3.4"}"
    curl -o "${FILENAME}" -LJ "https://github.com/pinokiocomputer/pinokio/releases/download/${VERSION}/Pinokio_${VERSION}_amd64.deb"
    apt-get install -y "./${FILENAME}"
    rm "./${FILENAME}"
    cd "${PWD}" || exit
}
main "$@"
