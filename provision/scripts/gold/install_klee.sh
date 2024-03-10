#! /bin/bash
set -e

requires \
    git \
    make
install_llvm() {
    apt-get update
    apt-get install --no-install-recommends -y \
        clang-13 \
        llvm-13 \
        llvm-13-dev \
        llvm-13-tools
    echo 'alias clang=clang-13' >> "${HOME}/.zshrc"
}
main() {
    install_llvm
    #
    # Install KLEE dependencies
    #
    apt-get update
    apt-get install --no-install-recommends -y \
        g++-multilib \
        gcc-multilib \
        libcap-dev \
        libgoogle-perftools-dev \
        libncurses5-dev \
        libsqlite3-dev \
        libtcmalloc-minimal4
    #
    # Install KLEE
    #
    local KLEE_SRC_DIRECTORY="/klee"
    mkdir -p "${KLEE_SRC_DIRECTORY}"
    git clone https://github.com/klee/klee.git /tmp/klee
    cd /tmp/klee || exit
    make -DENABLE_SOLVER_Z3=ON -DENABLE_POSIX_RUNTIME=ON "${KLEE_SRC_DIRECTORY}"
    cd "${KLEE_SRC_DIRECTORY}" || exit
    make
    cleanup
}
main "$@"