#! /bin/bash
set -e

requires curl
main() {
    #
    # Install Homebrew
    #
    touch /.dockerenv
    NONINTERACTIVE=1 \
    HOMEBREW_NO_INSTALL_FROM_API=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # shellcheck disable=SC2016
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.zshrc"
}
main "$@"
