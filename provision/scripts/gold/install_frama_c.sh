#! /bin/bash
set -e

requires \
    graphviz \
    libgtk2.0-dev \
    libgtk-3-dev \
    libcairo2-dev \
    libunwind-dev \
    opam
main() {
    export OPAMYES=1
    opam install frama-c --update-invariant
    eval "$(opam env)"
    opam upgrade
}
main "$@"