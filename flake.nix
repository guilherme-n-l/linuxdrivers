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
        stdenv = pkgs.stdenv;
        nativeBuildInputs = with pkgs; [pkg-config];

        configuredPkgs = {
          glibcPkg = pkgs.glibc;
          libgccPkg = pkgs.libgcc;
          clangPkg = pkgs.llvmPackages_21.clang-unwrapped;
          llvmBinUtilsPkg = pkgs.llvmPackages_21.bintools;
        };

        buildInputs =
          (with pkgs;
            [
              rustup
              rust-bindgen
              elfutils
              bc
              bison
              flex
              ncurses
              gnumake
              libc
            ]
            ++ (with llvmPackages_21; [
              clang-tools
            ]))
          ++ (with configuredPkgs; [glibcPkg clangPkg libgccPkg llvmBinUtilsPkg]) ++ (with stdenv; [cc.libc]);
        packages = with pkgs; [
          clippy
          gnugrep
          python3
          jq
          ripgrep
          envsubst
        ];
        shellHook = ''
          export PATH=${configuredPkgs.llvmBinUtilsPkg}/bin:$PATH
          export SRC_DIR=$PWD
          export LIBCLANG_PATH=${configuredPkgs.clangPkg.lib}/lib
          export C_INCLUDE_PATH=${configuredPkgs.glibcPkg.dev}/include:$C_INCLUDE_PATH
          export LIBRARY_PATH=${configuredPkgs.glibcPkg}/lib:${configuredPkgs.libgccPkg}/lib:$LIBRARY_PATH
          export LD_LIBRARY_PATH=${configuredPkgs.glibcPkg}/lib:${configuredPkgs.libgccPkg}/lib:$LD_LIBRARY_PATH

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
          inherit packages buildInputs nativeBuildInputs;
          shellHook =
            shellHook
            + ''
              [ -d "linux" ] || _init_repo
            '';
        };

        devShells.virt = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
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
