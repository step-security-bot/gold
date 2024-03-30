#! /bin/bash
# shellcheck disable=SC2016,SC2155
set -e

requires \
    brew \
    cargo \
    curl \
    git \
    gum \
    rustup
install_emscripten() {
    #
    # Install Emscripten tools (emsdk and emcc)
    #
    git clone https://github.com/emscripten-core/emsdk.git /emsdk
    cd /emsdk || exit
    ./emsdk install latest
    ./emsdk activate latest
    echo "$(gum style --foreground 46 '🗸') Installed $(gum style --foreground 46 Emscripten)"
    echo 'export EMSDK_QUIET=1' >> "${HOME}/.zshrc"
    echo 'source "/emsdk/emsdk_env.sh"' >> "${HOME}/.zshrc"
    cd "${HOME}" || exit
}
install_rust_targets_and_tools() {
    #
    # Install Rust WASM/WASI targets and tools
    #
    gum spin --title 'Adding WASI target' -- rustup target add wasm32-wasi
    gum spin --title 'Adding WASM Unknown target' -- rustup target add wasm32-unknown-unknown --toolchain nightly
    gum spin --title 'Install WASM/WASI related crates' -- cargo install \
        cargo-wasi \
        cargo-wasix \
        wasm-bindgen-cli \
        wasm-pack \
        wasm-tools
}
main() {
    #
    # Use gum to select runtimes
    #
    local EMPTY="[ ] "
    local BIN_DIRECTORY="${1:-/usr/local/bin}"
    local COLOR="${GOLD_FOREGROUND_COLOR:-220}"
    local TITLE="Install $(gum style --foreground "${COLOR}" 'WASM') tools & tech"
    local CHECKMARK="$(gum style --foreground 46 '🗸')"
    gum style \
        --border normal \
        --border-foreground "${COLOR}" \
        --margin "1" \
        --padding "1 2" \
        "${TITLE}"
    DATA="""
        Cosmonic:cosmo
        Emscripten:emcc
        Scale:scale
        Spin:spin
        Wasm3:wasm3
        WasmCloud:wash
        WasmEdge:wasmedge
        Wasmer:wasmer
        Wasmtime:wasmtime
        WAVM:wavm
        Wazero:wazero
        WEPL:wepl
        WWS:wws
    """
    COUNT=0
    MESSAGE=''
    for LINE in ${DATA}; do
        TECHNOLOGY=$(echo "${LINE}" | cut -d':' -f1)
        COMMAND=$(echo "${LINE}" | cut -d':' -f2)
        if is_command "${COMMAND}"; then
            COUNT=$((COUNT + 1))
            MESSAGE+="    ${CHECKMARK} ${TECHNOLOGY} ($(gum style --faint ${COMMAND}))\n"
            DATA=$(echo "${DATA}" | sed "/${TECHNOLOGY}:${COMMAND}/d")
        fi
    done
    if [[ "${COUNT}" -gt 0 ]]; then
        echo 'The following are already {{ Color "46" "installed" }}' | gum format -t template
        echo -e "${MESSAGE}\n" | gum format -t template
    fi
    CHOICES=$(echo "${DATA}" | cut -d':' -f1)
    gum confirm 'Add Rust WASM targets and tools?' && install_rust_targets_and_tools
    # shellcheck disable=SC2046,SC2068,SC2116,SC2154
    CHOSEN=$(gum choose \
        --no-limit \
        --cursor-prefix="${EMPTY}" \
        --header="Please select items to install" \
        --selected="${SELECTED}" \
        --selected.foreground="${COLOR}" \
        --selected-prefix="[X] " \
        --unselected-prefix="${EMPTY}" \
        $(echo "${CHOICES}"))
    for CHOICE in ${CHOSEN}; do
        case "${CHOICE}" in
            Cosmonic)
                bash -c "$(curl -fsSL https://cosmonic.sh/install.sh)"
                echo 'export PATH="/root/.cosmo/bin:${PATH}"' >> "${HOME}/.zshrc"
                export PATH="/root/.cosmo/bin:${PATH}"
                ;;
            Emscripten)
                install_emscripten
                source "/emsdk/emsdk_env.sh"
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
                cd "${HOME}" || exit
                ;;
            Wasm3)
                gum spin --title "(1 of 2) Installing Wasm3" -- brew install wasm3
                echo "${CHECKMARK} Installed $(gum style --foreground 46 Wasm3)"
                gum spin --title '(2 of 2) Performing Brew cleanup' -- brew cleanup --prune=all
                ;;
            WasmCloud)
                #
                # WAsmCloud SHell (wash)
                #
                gum spin --title 'Updating package list' -- apt-get update
                curl -s https://packagecloud.io/install/repositories/wasmcloud/core/script.deb.sh | bash
                apt-get install --no-install-recommends -y wash
                cleanup
                ;;
            WasmEdge)
                curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash
                echo '. "${HOME}/.wasmedge/env"' >> "${HOME}/.zshrc"
                # shellcheck disable=SC1091
                . "${HOME}/.wasmedge/env"
                ;;
            Wasmer)
                gum spin --title "(1 of 3) Installing wapm" -- brew install wapm
                echo "${CHECKMARK} Installed $(gum style --foreground 46 wapm)"
                gum spin --title "(2 of 3) Installing wasmer" -- brew install wasmer
                echo "${CHECKMARK} Installed $(gum style --foreground 46 wasmer)"
                gum spin --title '(3 of 3) Performing Brew cleanup' -- brew cleanup --prune=all
                ;;
            Wasmtime)
                curl https://wasmtime.dev/install.sh -sSf | bash
                echo 'export WASMTIME_HOME="${HOME}/.wasmtime"' >> "${HOME}/.zshrc"
                echo 'export PATH="${WASMTIME_HOME}/bin:${PATH}"' >> "${HOME}/.zshrc"
                export WASMTIME_HOME="${HOME}/.wasmtime"
                export PATH="${WASMTIME_HOME}/bin:${PATH}"
                ;;
            WAVM)
                local VERSION=${1:-"0.0.0-prerelease-linux"}
                local FILENAME='wavm.deb'
                cd /tmp || exit
                curl -o "${FILENAME}" -LJ "https://github.com/WAVM/WAVM/releases/download/nightly%2F2022-05-14/wavm-${VERSION}.deb"
                apt-get install -y "./${FILENAME}"
                rm "./${FILENAME}"
                cd "${HOME}" || exit
                ;;
            Wazero)
                local INSTALL_DIRECTORY=./bin
                cd /tmp || exit
                curl https://wazero.io/install.sh | sh
                mv "${INSTALL_DIRECTORY}/wazero" "${BIN_DIRECTORY}"
                rm -frd "${INSTALL_DIRECTORY}"
                cd "${HOME}" || exit
                ;;
            WEPL)
                #
                # WebAssembly REPL
                #
                local INSTALL_DIRECTORY=/tmp/wepl
                git clone https://github.com/rylev/wepl "${INSTALL_DIRECTORY}"
                cd "${INSTALL_DIRECTORY}" || exit
                cargo install --path . --locked
                cd "${HOME}" || exit
                rm -frd "${INSTALL_DIRECTORY}"
                ;;
            WWS)
                #
                # WASM workers server (wws)
                #
                cd "${BIN_DIRECTORY}" || exit
                curl -fsSL https://workers.wasmlabs.dev/install | bash -s -- --local
                cd "${HOME}" || exit
                ;;
            *)
                exit 1
                ;;
        esac
    done
}
main "$@"
