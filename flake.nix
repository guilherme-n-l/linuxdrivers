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
      in {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            qemu
          ];

          shellHook = ''
          source ./scripts/utils.sh
          echo "Linux Driver dev environment"
          echo -e "Use \`help\` for a list of commands\n"
          qemu-system-x86_64 --version | head -n 1
          '';
        };
      }
    );
}
