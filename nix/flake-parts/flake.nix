{
  description = "a flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    mccurdyc-rust = "path:./nix/flake.nix";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      # https://flake.parts/module-arguments.html#persystem-module-parameters
      # self' - The flake self parameter, but with system pre-selected.
      perSystem = { self', ... }: {
        mccurdyc-rust = {
          # where you would set module options
        };

        devShells.default = self'.devShells.rust;
      };
    };
}
