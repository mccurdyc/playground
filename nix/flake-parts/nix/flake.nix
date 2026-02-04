{
  description = "My Rust development preferences as a Flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { rust-overlay, ... }: {
    # These are proper Nix modules. However, it's flake-parts that handles
    # the consumption of these modules and exposing them as perSystem flake fields
    # in the top-level, consuming, flake.
    #
    # This is what exposes these modules to the top-level flake using flake-parts.
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
