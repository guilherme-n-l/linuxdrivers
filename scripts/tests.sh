#!/bin/bash

: "${SRC_DIR:=.}"

source ${SRC_DIR}/scripts/env.sh

_test() {
    if "$1"; then
        echo -e "\t\033[0;32m[OK]\033[0m $2"
    else
        echo -e "\t\033[0;31m[FAIL]\033[0m $2"
    fi
}

_test_has_linux() {
    [ -d "$SRC_DIR/${LINUX_DIR#/}" ]
}

_test_has_driver() {
    cd "$full_driver_path" &> /dev/null || return 1

    git rev-parse --git-dir &> /dev/null 
}

_test_rust_available() {
    cd "$full_linux_path" &> /dev/null || return 1

    make rustavailable &> /dev/null
}

_test_rust-analyzer_available() {
    rust-analyzer --version
}

_test_linux_config() {
    configs=(
    "CONFIG_RUST=y"
    "CONFIG_R8169_RS=[m|y]"
    "CONFIG_RUST_DEBUG_ASSERTIONS=y"
    "CONFIG_RUST_OVERFLOW_CHECKS=y"
    )

    cd "$full_linux_path" &> /dev/null || return 1

    for expr in "${configs[@]}"; do
        grep -Pq "$expr" "${full_linux_path}/.config" || { echo "/$expr/ not matched"; return 1; }
    done
}

test() {(
    echo "Running tests:"
    _test _test_has_linux "HAS_LINUX"
    _test _test_has_driver "HAS_DRIVER"
    _test _test_rust_available "IS_RUST_AVAILABLE"
    _test _test_rust_available "IS_RUST-ANALYZER_AVAILABLE"
    _test _test_linux_config "IS_LINUX_CONFIGURED"
)}
