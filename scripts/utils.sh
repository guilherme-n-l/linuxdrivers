#!/bin/bash

IMG_NAME="img.qcow2"
SHARED_DIR="./shared"

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

_github_clone() {
    repo="$1"

    if ! git clone "git@github.com:${repo}.git"; then
        echo "SSH clone failed falling back to http"
        git clone "https://github.com/${repo}.git"
    fi
}

_init_rust() {
    rustc --version &> /dev/null || rustup default stable &> /dev/null
}

_init_repo() {
    linux_dir="linux"
    driver_path="drivers/net/ethernet/realtek/r8169_rs" # Path inside linux dir. e.g.: `drivers/...`

    if [ ! -d "$linux_dir" ] || [ _confirm "Replacing repository" ]; then
        _github_clone "guilherme-n-l/linux"

        full_driver_path="${linux_dir%/}/${driver_path#/}"
        full_driver_path="${full_driver_path%/}"

        rm -rf "$full_driver_path"

        _github_clone "guilherme-n-l/r8169_rs"
    fi

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

    qemu-system-x86_64                                                                      \
        -drive file="$IMG_NAME",format=qcow2                                                \
        -boot order=d                                                                       \
        -m 4G                                                                               \
        -netdev user,id=user0,hostfwd=tcp::2222-:22                                         \
        -device virtio-net-pci,netdev=user0                                                 \
        -virtfs local,path=${SHARED_DIR},mount_tag=hostshare,security_model=mapped-xattr    \
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

vprint() {
    while IFS= read -r ln; do
        printf "\t%s\n" "$ln"
    done
}
