#! /bin/bash
set -e

requires \
    curl \
    gum
main() {
    local EMPTY="[ ] "
    local COLOR="${GOLD_FOREGROUND_COLOR:-220}"
    local NOTEBOOKS_DIR=${1:-'/root/dev/notebooks'}
    gum style --border normal --margin "1" --padding "1 2" --border-foreground "${COLOR}" "Download $(gum style --foreground "${COLOR}" 'notebooks')"
    DATA="""
        C#:csharp
        Clojure:clojure
        Elixir:elixir
        F#:fsharp
        Golang:go
        Haskell:haskell
        JavaScript:javascript
        Julia:julia
        Kotlin:kotlin
        Lua:lua
        Python:python
        PowerShell:powershell
        R:R
        Ruby:ruby
        Rust:rust
        Scala:scala
        Swift:swift
    """
    CHOICES=$(echo "${DATA}" | cut -d':' -f1)
    # shellcheck disable=SC2010
    NOTEBOOKS=$(ls "${NOTEBOOKS_DIR}" | grep 'ipynb$' | cut -d'.' -f1)
    EXISTING="$(echo "${DATA}" | grep "${NOTEBOOKS}$" | cut -d':' -f1)"
    if [[ -z ${NOTEBOOKS[@]} ]]; then
        SELECTED=''
    else
        SELECTED=$(echo ${EXISTING[@]} | sed -r 's/[[:blank:]]+/,/g')
    fi
    # shellcheck disable=SC2046,SC2068,SC2116
    CHOSEN=$(gum choose \
        --no-limit \
        --cursor-prefix="${EMPTY}" \
        --header="Please select notebook(s)" \
        --selected=${SELECTED} \
        --selected.foreground="${COLOR}" \
        --selected-prefix="[x] " \
        --unselected-prefix="${EMPTY}" \
        $(echo "${CHOICES}"))
    LANGUAGES=$(echo "${DATA}" | grep "${CHOSEN}" | cut -d':' -f2)
    echo $LANGUAGES
    exit
    mkdir -p "${NOTEBOOKS_DIR}"
    cd "${NOTEBOOKS_DIR}" || exit
    for LANGUAGE in ${LANGUAGES}; do
        URL="https://raw.githubusercontent.com/jhwohlgemuth/language-comparison/main/${LANGUAGE}.ipynb"
        curl --create-dirs --silent -O "${URL}"
    done
    cd /root || exit
}
main "$@"
