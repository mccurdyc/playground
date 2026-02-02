{ config, pkgs, ... }:

{
  config.devShells.rust =
    let
      inherit (config.mccurdyc-rust) toolchain;

    in
    pkgs.mkShell {
      name = "rust-devshell";
      meta.description = "Rust development environment";

      shellHook = ''
        # For rust-analyzer 'hover' tooltips to work.
        export RUST_SRC_PATH="${toolchain}/lib/rustlib/src/rust/library";
      '';

      buildInputs = [
        pkgs.libiconv
      ];

      packages = [
        toolchain
      ];
    };
}
