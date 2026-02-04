{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    mccurdyc-rust.url = "path:./nix";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      # These "merge" into self' to be used below. You can't reference
      # inputs or inputs' because flake-parts hasn't evaluated inputs as a Nix module.
      imports = [
        inputs.mccurdyc-rust.flakeModules.default
      ];
      # https://flake.parts/module-arguments.html#persystem-module-parameters
      # self' - The flake self parameter, but with system pre-selected.
      perSystem = { self', ... }: {
        # mccurdyc-rust = {
        #   # where you would set module options
        # };

        devShells.default = self'.devShells.rust;
      };
    };
}
