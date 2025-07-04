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
          # https://github.com/envoyproxy/envoy/blob/e439c73e32dfefff0baa4adedfb268c8742a7617/bazel/repository_locations.bzl#L1161-L1175
          # https://github.com/hsjobeki/nixpkgs/blob/43bceee4fd57058437d9ec90eae7c1b280509653/pkgs/build-support/fetchgithub/default.nix#L4
          com_github_wasmtime = pkgs.fetchFromGitHub {
            owner = "bytecodealliance";
            repo = "wasmtime";
            # matches version in upstream envoy
            # https://github.com/mccurdyc/envoy/blob/6371b185dee99cd267e61ada6191e97f2406e334/bazel/repository_locations.bzl#L1165
            # 24.0.2 - https://github.com/bytecodealliance/wasmtime/releases/tag/v24.0.2
            rev = "c29a9bb9e23b48a95b0a03f3b90f885ab1252a93";
            sha256 = "sha256-pqPyy1evR+qW0fEwIY4EnPDPwB4bKrym3raSs6jezP4=";
          };

          proxy_wasm_cpp_host = pkgs.fetchFromGitHub {
            owner = "proxy-wasm";
            repo = "proxy-wasm-cpp-host";
            # matches version in upstream envoy
            # https://github.com/mccurdyc/envoy/blob/6371b185dee99cd267e61ada6191e97f2406e334/bazel/repository_locations.bzl#L1407
            rev = "c4d7bb0fda912e24c64daf2aa749ec54cec99412";
            # sha256 = pkgs.lib.fakeSha256;
            sha256 = "sha256-NSowlubJ3OK4h2W9dqmzhkgpceaXZ7ore2cRkNlBm5Q=";
            # Do we need to somehow also tell envoy that this is used for extensions or is this only doing the override of fetching the source?
          };

          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;

            overlays = [
              (_: super: {

                envoy = super.envoy.overrideAttrs (old: {
                  src = pkgs.applyPatches {
                    inherit (old) src;

                    patches = [
                      # https://github.com/mccurdyc/envoy/blob/6371b185dee99cd267e61ada6191e97f2406e334/api/bazel/envoy_http_archive.bzl#L4-L9 
                      # Envoy's Bazel WONT fetch repos that are listed in the existing_rules list
                      ./patches/0001-com_github_wasmtime_from_nix.patch
                      ./patches/0001-proxy_wasm_cpp_host_from_nix.patch
                    ];

                    postPatch = ''
                      # https://nixos.org/manual/nixpkgs/unstable/#fun-substitute
                      substituteInPlace WORKSPACE --subst-var-by com_github_wasmtime_from_nix ${com_github_wasmtime}
                      substituteInPlace WORKSPACE --subst-var-by proxy_wasm_cpp_host_from_nix ${proxy_wasm_cpp_host}
                    '';
                  };

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
