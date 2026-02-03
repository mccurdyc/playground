# A nix module that produces a module per-system.
#
# Ultimately, we are producing a config object that is directly consumable in a flake.

# Bundles inputs with my (the provider) flake. Making it easier to consume, but at a cost to flexibility.
providerInputs:

{ lib, config, self, flake-parts-lib, ... }: # consumer's inputs i.e., these come from the consuming flake.
{
  # flake-level attributes
  # declare options
  options = {
    # Given a module, construct an option declaration suitable for merging into the core `perSystem` module
    perSystem = flake-parts-lib.mkPerSystemOption

      # module per-system
      # https://flake.parts/module-arguments.html#persystem-module-parameters
      ({ ... }: {
        imports = [
          ./devshell.nix
        ];

        # declare options
        # options = {
        #   mccurdyc-rust = {
        #     toolchain = lib.mkOption {
        #       type = lib.types.package;
        #       description = "Rust toolchain to use for the rust-project package";
        #       default = (pkgs.rust-bin.fromRustupToolchainFile (self + /rust-toolchain.toml)).override {
        #         extensions = [
        #           "rust-src"
        #           "rust-analyzer"
        #           "clippy"
        #         ];
        #       };
        #       defaultText = lib.literalMD ''
        #         Based on the `rust-toolchain.toml` file in the flake directory
        #       '';
        #     };
        #   };
        # };

        # output
        # define values
        config = { };
      });

    nixpkgs.overlays = [
      (import providerInputs.rust-overlay)
    ];
  };
}
