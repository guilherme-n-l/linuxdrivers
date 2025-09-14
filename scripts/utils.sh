#!/bin/bash

IMG_NAME="img.qcow2"

_confirm() {
    echo -n "$1 [y/N]: "
    read response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

_read_num() {
    echo -n "$1" 1>&2
    read num

    while [[ ! "$num" =~ ^[0-9]+$ ]]; do
        echo "Invalid input. Please enter a valid number" 1>&2
        echo -n "$1" 1>&2
        read num
    done

    echo $num
}

help() {
    declare -A functions=(
        ["create_disk"]="Create qcow2 virtual disk w/ qemu-img"
        ["boot_iso"]="Boot ISO to virtual disk using 4G RAM. Example: \`boot_iso ./archlinux.iso\`"
        ["boot"]="\tBoot to virtual disk using 4G RAM"
    )

    echo "Shell environment available commands:"

    for cmd in "${!functions[@]}"; do
        echo -e "\t$cmd:\t${functions[$cmd]}"
    done
}

create_disk() {
    size=$(_read_num "SELECT IMAGE SIZE (in GB): ")

    _confirm "Creating $IMG_NAME with $size GB" || {
            echo "Aborting..."
            return 1
    }

    [[ -f "./$IMG_NAME" ]] && { 
        _confirm "$IMG_NAME already exits, replace?" && \
        rm -rf "./$IMG_NAME"
    } || {
        echo "Aborting..."
        return 1
    }

    qemu-img create -f qcow2 "$IMG_NAME" "${size}G"
}

boot() {
    system_args=""
    case "$(uname -s)" in
        "Darwin") system_args+="
            -display cocoa
            -vga std
            " ;;
        "Linux") system_args+="-enable-kvm" ;;
        *) return 1 ;;
    esac
    extra_args="$system_args $1"

    qemu-system-x86_64                          \
        -drive file="$IMG_NAME",format=qcow2    \
        -boot order=d                           \
        -m 4G                                   \
        $extra_args
}

boot_iso() {
    [[ ! -f "./$IMG_NAME" ]] && { 
        echo "Image not found in PWD"
        echo "Aborting..."
        return 1
    }

    [[ -z "$1" ]] || [[ ! -f "$1" ]] && { 
        echo "ISO not provided or not found"
        echo "Aborting..."
        return 1
    }

    boot "-cdrom $1"
}
