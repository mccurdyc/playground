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

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;

            overlays = [
              (self: super: {

                # We use overrideDerivation even though it's strongly advised against in the nixpkgs
                # manual because we need to override nativeBuildInputs with dependencies that are
                # not fetchable during build time and since nativeBuildInputs is not exposed
                # via nixpkgs/envoy, we can't use overrideAttrs or override.
                #
                # Evaluates a derivation before modifying it
                #
                # The function overrideDerivation creates a new derivation based on an existing one by overriding the original’s attributes with the attribute set produced by the specified function. This function is available on all derivations defined using the makeOverridable function. Most standard derivation-producing functions, such as stdenv.mkDerivation, are defined using this function, which means most packages in the nixpkgs expression, pkgs, have this function.
                envoy = super.envoy.overrideDerivation (oldAttrs: {
                  stdenv = super.stdenv;

                  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
                    pkgs.wasmtime
                  ];

                  #patches = [
                  # Something that replaces Bazel's com_github_wasmtime so that bazel doesnt try to install inside
                  # the build vm and instead uses either pkg.wasmtime if it
                  # just needs a binary OR we'll have to use fetchFromGitHub and
                  # probably put in the bazel build dir.
                  #];

                  wasmRuntime = "wasmtime";
                });
              })
            ];
          };

          pkgs-unstable = import
            inputs.nixpkgs-unstable
            {
              inherit system;
              config.allowUnfree = true;
            };

          ci_packages = {
            # Nix
            nix-fmt = pkgs.nixpkgs-fmt;

            # General
            inherit (pkgs-unstable) just; # need just >1.33 for working-directory setting
          };

          packages = (builtins.attrValues ci_packages) ++ [
            pkgs.statix
            pkgs.nixpkgs-fmt
            pkgs-unstable.nil
            pkgs.hadolint
            pkgs.yamllint
            pkgs.yamlfmt
            pkgs-unstable.prometheus.cli

            # Kubernetes
            pkgs.k3d
            pkgs.k9s
            pkgs.kubie
            pkgs.kubernetes-helm
            pkgs.kubernetes
            pkgs.tilt

            pkgs.envoy
          ];
        in
        {
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
                shfmt = {
                  enable = true;
                  entry = "shfmt --simplify --indent 2";
                };

                yamlfmt = {
                  enable = true;
                  # https://github.com/google/yamlfmt/blob/main/docs/config-file.md#basic-formatter
                  entry = "yamlfmt -formatter indent=2,include_document_start=true,retain_line_breaks=true";
                };
              };
            };
          };

          packages = {
            default = pkgs.envoy;
          };

          devShells.default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            inherit packages;
          };
        };
    };
}
