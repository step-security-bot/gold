#! /bin/bash
set -e

requires \
    graphviz \
    gtksourceview-3.0 \
    libgtk2.0-dev \
    libgtk-3-dev \
    libcairo2-dev \
    libunwind-dev \
    opam \
    why3
main() {
    export OPAMYES=1
    opam install frama-c --no-depext --update-invariant
    eval "$(opam env)"
    opam upgrade
    why3 config detect
}
main "$@"