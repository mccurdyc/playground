{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = { };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      # This is needed for pkgs-unstable - https://github.com/hercules-ci/flake-parts/discussions/105
      imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.permittedInsecurePackages = [
              "vault-bin-1.15.6"
            ];
          };
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          # This is needed for pkgs-unstable - https://github.com/hercules-ci/flake-parts/discussions/105
          overlayAttrs = { inherit pkgs-unstable; };

          formatter = pkgs.nixpkgs-fmt;

          # https://github.com/cachix/git-hooks.nix
          # 'nix flake check'
          checks = {
            pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                # Nix
                deadnix.enable = true;
                nixpkgs-fmt.enable = true;
                statix.enable = true;

                # Shell
                shellcheck.enable = true;
                shfmt.enable = true;
              };
            };
          };

          devShells.default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;

            # https://github.com/NixOS/nixpkgs/blob/736142a5ae59df3a7fc5137669271183d8d521fd/doc/build-helpers/special/mkshell.section.md?plain=1#L1
            packages =
              let
                pinned_cue = pkgs.callPackage (import ./nix/github.nix) {
                  inherit system;
                  org = "cue-lang";
                  name = "cue";
                  version = "v0.13.2";
                  # 'nix-prefetch-url https://github.com/cue-lang/cue/releases/download/v0.14.0-alpha.2/cue_v0.14.0-alpha.2_darwin_arm64.tar.gz'
                  # https://github.com/NixOS/nixpkgs/blob/54b4bb956f9891b872904abdb632cea85a033ff2/doc/build-helpers/fetchers.chapter.md#update-source-hash-with-the-fake-hash-method
                  sha256 = {
                    "x86_64-linux" = "1fgg9fggrgm3zvg8ymxvxrimkp5sw8as1m9nrslgzm7mpn3qg953";
                    "aarch64-darwin" = "0bcf3g11fm5ab9276hk6hh17g8py3s81007g38srjd700x6qd66h";
                  }.${system};
                };
              in
              [
                # Nix
                pkgs.statix
                pkgs.nixpkgs-fmt
                pkgs-unstable.nil

                # Cue
                pkgs-unstable.cuelsp
                pkgs-unstable.nil
                pinned_cue
              ];
          };
        };
    };
}
