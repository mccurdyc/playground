# nix run '.#default'
# or; nix run
# https://github.com/DeterminateSystems/zero-to-nix/blob/main/flake.nix
# https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-flake.html#flake-format
{
  description = "something useful";
  inputs = {
    # These must be flakes

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # https://lazamar.co.uk/nix-versions/?package=yarn&version=1.22.19&fullName=yarn-1.22.19&keyName=yarn&revision=336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3&channel=nixpkgs-unstable#instructions
    # nixpkgs-foo.url = "https://github.com/NixOS/nixpkgs/archive/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3.tar.gz";
  };

  #TODO: https://determinate.systems/posts/flake-schemas/
  # im not sure i understand the value. the lock-in is high though.
  # https://wiki.nixos.org/wiki/Flakes#Output_schema
  outputs = { self, nixpkgs, ... }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # You should use flake-parts (or; flake-utils) instead of this, but I'm explicitly trying not to.
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        # These get passed to whatever function you define
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });

      # Helper function for scripting
      runPkg = pkgs: pkg: "${pkgs.${pkg}}/bin/${pkg}";

      isoConfig = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
    in
    {
      # https://nix.dev/tutorials/nixos/nixos-configuration-on-vm.html
      # 1/ nix develop '.#builder'
      # 2/ nixos-generate-config --dir ./vm-config
      # 3/ remove hard-configuration things
      devShells = forAllSystems
        ({ pkgs, system }:
          let
            nixos = pkgs.nixos isoConfig;
          in
          {
            builder = pkgs.mkShell {
              buildInputs = [ nixos.config.system.build.nixos-generate-config ];
            };
          });

      # 1/ nix eval --impure '.#nixosConfigurations.x86_64-linux.vm' --apply builtins.attrNames
      # 2/ nix eval --impure '.#nixosConfigurations.x86_64-linux.vm.config.system.build.vm' --apply builtins.attrValues
      # 3/ QEMU_KERNEL_PARAMS=console=ttyS0 $(nix build --print-out-paths '.#nixosConfigurations.x86_64-linux.vm.config.system.build.vm')/bin/run-nixos-vm -nographic; reset
      nixosConfigurations = forAllSystems
        ({ system, ... }: {
          vm = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./vm-config/configuration.nix
            ];
          };
        });

      packages = forAllSystems
        ({ pkgs, ... }: {
          # https://nixos.org/manual/nixpkgs/stable/#chap-trivial-builders
          sayHello = pkgs.writeShellApplication
            {
              name = "sayHello";
              runtimeInputs = [ pkgs.bash ];
              text = ''
                echo "Hello, $1"
              '';
            };
        });

      # https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-run.html#apps
      apps = forAllSystems ({ pkgs, system }:
        let
          run = pkg: runPkg pkgs pkg;

          common = builtins.fetchGit {
            url = "ssh://git@github.com/mccurdyc/playground.git";
            # NOTE: you have to give it a commit for hermetic builds, you CANNOT use a branch name.
            rev = "6da84fffe8d054c36d5de7c40094af9e61ee8911";
          };
        in
        {
          default = {
            type = "app";
            program = "${run "hello"}";
          };

          sayHello = {
            type = "app";
            program = "${self.packages.${system}.sayHello}/bin/sayHello";
          };

          remoteHello = {
            type = "app";
            program = "${pkgs.callPackage "${common}/nix/common/hello.nix" {
              inherit pkgs;
              name = "motloc";
            }}/bin/sayHello";
          };
        });
    };
}
