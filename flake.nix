{
  description = "Flake for linuxdrivers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        packages = with pkgs; [
          clippy
          rustup
          rust-bindgen
          elfutils
          bc
          bison
          flex
          ncurses
          gnumake
          gnugrep
          python3
          jq
        ];
        shellHook = ''
          export SRC_DIR=$PWD
          source ./scripts/utils.sh
          echo "Linux Driver dev environment"
          echo -e "Use \`help\` for a list of commands\n"

          _init_rust

          echo "Versions:"
          for cmd in rustc rustup clippy-driver bindgen; do
                $cmd --version 2> /dev/null | head -n 1 | vprint
          done
        '';
      in {
        devShells.default = pkgs.mkShell {
          inherit packages;
          shellHook =
            shellHook
            + ''
              [ -d "linux" ] || _init_repo
            '';
        };

        devShells.virt = pkgs.mkShell {
          shellHook =
            shellHook
            + ''
              qemu-system-x86_64 --version | head -n 1 | vprint
            '';
          packages = packages ++ [pkgs.qemu];
        };
      }
    );
}
