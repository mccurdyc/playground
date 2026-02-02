# A nix module that produces a module per-system.
#
# Ultimately, we are producing a config object that is directly consumable in a flake.
#
# provider's inputs to allow partial apply from the module's flake and not require consumer to specify inputs.
# This will proxy any inputs defined in the consuming flake through as `providerInputs.<something>`
# See - https://flake.parts/dogfood-a-reusable-module#example-with-importapply
providerInputs:

{ lib, config, self, flake-parts-lib, ... }: # consumer's inputs

let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  # declare options
  options = {

    # Given a module, construct an option declaration suitable for merging into the core `perSystem` module
    perSystem = mkPerSystemOption

      # module per-system
      # https://flake.parts/module-arguments.html#persystem-module-parameters
      ({ pkgs, ... }: {
        imports = [
          ./devshell.nix
        ];

        # declare options
        options = {
          mccurdyc-rust = {

            toolchain = lib.mkOption {
              type = lib.types.package;
              description = "Rust toolchain to use for the rust-project package";
              default = (pkgs.rust-bin.fromRustupToolchainFile (self + /rust-toolchain.toml)).override {
                extensions = [
                  "rust-src"
                  "rust-analyzer"
                  "clippy"
                ];
              };
              defaultText = lib.literalMD ''
                Based on the `rust-toolchain.toml` file in the flake directory
              '';
            };
          };

          # This is also the "output"
          # define values
          config = {
            # See nix/modules/nixpkgs.nix (the user must import it)
            nixpkgs.overlays = [
              (import providerInputs.rust-overlay)
            ];
          };

        };
      });
  };
}
