# nix run '.#default'
# or; nix run
# https://github.com/DeterminateSystems/zero-to-nix/blob/main/flake.nix
{
  description = "something useful";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*";
  outputs = { self, nixpkgs }:

    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      # Helper function for scripting
      runPkg = pkgs: pkg: "${pkgs.${pkg}}/bin/${pkg}";
    in
    {
      apps = forAllSystems ({ pkgs }:
        let
          run = pkg: runPkg pkgs pkg;
        in
        {
          default = {
            type = "app";
            program = "${run "hello"}";
          };
        });
    };
}
