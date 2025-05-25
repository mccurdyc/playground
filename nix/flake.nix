# nix run '.#default'
# or; nix run
# https://github.com/DeterminateSystems/zero-to-nix/blob/main/flake.nix
# https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-flake.html#flake-format
{
  description = "something useful";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # https://lazamar.co.uk/nix-versions/?package=yarn&version=1.22.19&fullName=yarn-1.22.19&keyName=yarn&revision=336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3&channel=nixpkgs-unstable#instructions
    # nixpkgs-foo.url = "https://github.com/NixOS/nixpkgs/archive/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3.tar.gz";

    common.url = "path:./common";
  };


  #TODO: https://determinate.systems/posts/flake-schemas/
  # im not sure i understand the value. the lock-in is high though.
  # https://wiki.nixos.org/wiki/Flakes#Output_schema
  outputs = { self, nixpkgs, common, ... }:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
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

    in
    {
      packages = forAllSystems
        ({ pkgs, system }: {
          # https://nixos.org/manual/nixpkgs/stable/#chap-trivial-builders
          sayHello = pkgs.writeShellApplication
            {
              name = "sayHello";
              runtimeInputs = [ pkgs.bash ];
              text = ''
                echo "${common.lib.sayHello "motloc"}"
              '';
            };
        });

      # https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-run.html#apps
      apps = forAllSystems ({ pkgs, system }:
        let
          run = pkg: runPkg pkgs pkg;

          remoteSrc = pkgs.fetchFromGitHub {
            owner = "mccurdyc";
            repo = "playground";
            # rev is latest by default
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

          remoteHello = pkgs.callPackage "${remoteSrc}/nix/common/hello.nix" {
            inherit pkgs;
            name = "motloc";
          };
        });
    };
}
