#! /bin/bash
set -e

requires \
    brew \
    cargo \
    curl \
    gum \
    rustup
main() {
    #
    # Install Rust WASM/WASI targets and tools
    #
    rustup target add wasm32-wasi
    rustup target add wasm32-unknown-unknown --toolchain nightly
    cargo install \
        cargo-wasi \
        wasm-bindgen-cli \
        wasm-pack
    #
    # Use gum to select runtimes
    #
    local EMPTY="[ ] "
    local BIN_DIRECTORY="${1:-/usr/local/bin}"
    local COLOR="${GOLD_FOREGROUND_COLOR:-220}"
    gum style \
        --border normal \
        --border-foreground "${COLOR}" \
        --margin "1" \
        --padding "1 2" \
        "Install $(gum style --foreground "${COLOR}" 'WASM runtimes')"
    DATA="""
        Cosmonic:cosmo
        Scale:scale
        Spin:spin
        Wasm3:wasm3
        WasmCloud:wash
        WasmEdge:wasmedge
        Wasmer:wasmer
        Wasmtime:wasmtime
        Wazero:wazero
        WWS:wws
    """
    COUNT=0
    MESSAGE=''
    for LINE in ${DATA}; do
        RUNTIME=$(echo "${LINE}" | cut -d':' -f1)
        COMMAND=$(echo "${LINE}" | cut -d':' -f2)
        if is_command "${COMMAND}"; then
            COUNT=$((COUNT + 1))
            MESSAGE+="    $(gum style --foreground 46 '🗸') ${RUNTIME}\n"
        fi
    done
    if [ "${COUNT}" -gt 0 ]; then
        echo '{{ Italic "NOTE" }}: The following runtimes are already {{ Color "46" "installed" }}' | gum format -t template
        echo -e "${MESSAGE}\n" | gum format -t template
    fi
    CHOICES=$(echo "${DATA}" | cut -d':' -f1)
    # shellcheck disable=SC2046,SC2068,SC2116
    CHOSEN=$(gum choose \
        --no-limit \
        --cursor-prefix="${EMPTY}" \
        --header="Please select runtime(s)" \
        --selected="${SELECTED}" \
        --selected.foreground="${COLOR}" \
        --selected-prefix="[X] " \
        --unselected-prefix="${EMPTY}" \
        $(echo "${CHOICES}"))
    for CHOICE in ${CHOSEN}; do
        case "${CHOICE}" in
            Cosmonic)
                bash -c "$(curl -fsSL https://cosmonic.sh/install.sh)"
                # shellcheck disable=SC2016
                echo 'export PATH="/root/.cosmo/bin:${PATH}"' >> "${HOME}/.zshrc"
                export PATH="/root/.cosmo/bin:${PATH}"
                ;;
            Scale)
                curl -fsSL https://dl.scale.sh | sh
                ;;
            Spin)
                #
                # Spin microservices server (spin)
                #
                cd "${BIN_DIRECTORY}" || exit
                curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
                rm -frd crt.pem LICENSE README.md spin.sig
                ;;
            Wasm3)
                gum spin --title "(1 of 2) Installing Wasm3" -- brew install wasm3
                echo "👍 Installed $(gum style --foreground 46 Wasm3)"
                gum spin --title '(2 of 2) Performing Brew cleanup' -- brew cleanup --prune=all
                ;;
            WasmCloud)
                #
                # WAsmCloud SHell (wash)
                #
                apt-get update
                curl -s https://packagecloud.io/install/repositories/wasmcloud/core/script.deb.sh | bash
                apt-get install --no-install-recommends -y wash
                cleanup
                ;;
            WasmEdge)
                curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash
                # shellcheck disable=SC2016
                echo '. "${HOME}/.wasmedge/env"' >> "${HOME}/.zshrc"
                # shellcheck disable=SC1091
                . "${HOME}/.wasmedge/env"
                ;;
            Wasmer)
                PACKAGES='wapm wasm3'
                local i=1
                for PACKAGE in ${PACKAGES}; do
                    gum spin --title "(${i} of 3) Installing ${PACKAGE}" -- brew install "${PACKAGE}"
                    echo "👍 Installed $(gum style --foreground 46 "${PACKAGE}")"
                    i=$((i + 1))
                done
                gum spin --title '(3 of 3) Performing Brew cleanup' -- brew cleanup --prune=all
                ;;
            Wasmtime)
                curl https://wasmtime.dev/install.sh -sSf | bash
                # shellcheck disable=SC2016
                echo 'export WASMTIME_HOME="${HOME}/.wasmtime"' >> "${HOME}/.zshrc"
                # shellcheck disable=SC2016
                echo 'export PATH="${WASMTIME_HOME}/bin:${PATH}"' >> "${HOME}/.zshrc"
                export WASMTIME_HOME="${HOME}/.wasmtime"
                export PATH="${WASMTIME_HOME}/bin:${PATH}"
                ;;
            Wazero)
                local INSTALL_DIRECTORY=./bin
                cd /tmp || exit
                curl https://wazero.io/install.sh | sh
                mv "${INSTALL_DIRECTORY}/wazero" "${BIN_DIRECTORY}"
                rm -frd "${INSTALL_DIRECTORY}"
                cd /root || exit
                ;;
            WWS)
                #
                # WASM workers server (wws)
                #
                cd "${BIN_DIRECTORY}" || exit
                curl -fsSL https://workers.wasmlabs.dev/install | bash -s -- --local
                ;;
            *)
                echo "Unknown runtime: ${CHOICE}"
                ;;
        esac
    done
}
main "$@"
