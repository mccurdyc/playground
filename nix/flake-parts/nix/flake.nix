{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { rust-overlay, ... }: {
    # Consumable modules by flakes consuming this rust flake.
    # This is what exposes these modules to the top-level flake.
    #
    # Nix doesn't restrict or validate flake output fields.
    # `flakeModules` is a convention defined by flake-parts.
    # It's similar to `nixosModules`.
    #
    # https://flake.parts/dogfood-a-reusable-module
    flakeModules = {
      default = import ./modules/flake-module.nix { inherit rust-overlay; };
    };
  };
}
