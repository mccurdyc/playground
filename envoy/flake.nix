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
          };
          pkgs-unstable = import inputs.nixpkgs-unstable {
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
          ];
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

          packages = ci_packages;

          devShells.default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            inherit packages;
          };
        };
    };
}
