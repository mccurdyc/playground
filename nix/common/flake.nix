{
  description = "Personal nix flake for common functions";

  inputs = { name };

  outputs = { self, nixpkgs, name}:
    let
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ name }: {
        sayHello = derivation {
          name = "hello";
          builder = "/bin/bash";
          args = [ "echo -n 'Hello there, ${name}!' > $out" ];
          system = builtins.currentSystem;
        };
      });
    };
}
