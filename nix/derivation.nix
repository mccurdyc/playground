# Usage: nix-instantiate --eval derivation.nix
#
# https://nix.dev/manual/nix/2.28/language/derivations.html
# The most important built-in function is derivation, which is used to describe
# a single store-layer store derivation. Consult the store chapter for what a store
# derivation is; this section just concerns how to create one from the Nix language.
# - https://nix.dev/manual/nix/2.28/store/derivation/#store-derivation
# - https://nix.dev/manual/nix/2.28/store/derivation/
#
# https://www.zombiezen.com/blog/2021/12/nix-from-the-ground-up/
# A derivation, upon evaluation, creates an immutable .drv file in the Nix store
# (typically located at /nix/store) named by the hash of the derivation’s inputs.
# A separate step, called realisation, ensures that the outputs of the derivation's
# builder program are available as an immutable directory in the Nix store, either
# by running the builder program or downloading the results of a previous run from a cache.
let
  # https://nix.dev/manual/nix/2.24/language/index.html
  # A lookup path for Nix files. Value determined by $NIX_PATH environment variable.
  # https://nix.dev/manual/nix/2.24/language/builtins.html#builtins-findFile
  # '<nixpkgs>' is equivalent to: 'builtins.findFile builtins.nixPath "nixpkgs"'
  # uses host's nixpkgs
  # nixpkgs=flake:nixpkgs:/nix/var/nix/profiles/per-user/root/channels
  # pkgs = import <nixpkgs> { };

  # https://nix.dev/manual/nix/2.24/language/builtins.html#builtins-fetchTree
  pkgsSrc = builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
  };
  pkgs = import pkgsSrc { };


  drv = derivation {
    name = "hello";
    # https://nix.dev/manual/nix/2.22/language/derivations
    # PATH is set to /path-not-set
    # HOME is set to /homeless-shelte
    # The temporary directory is removed (unless the -K option was specified).
    # Nix sets the last-modified timestamp on all files in the build result to 1 (00:00:01 1/1/1970 UTC), sets the group to the default group, and sets the mode of the file to 0444 or 0555 (i.e., read-only, with execute permission enabled if the file was originally executable).
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./builder ]; # this is NOT a string. Nix iterpolates this as a path.

    # Default: [ "out" ]
    # Symbolic outputs of the derivation. Each output name is passed to the builder
    # executable as an environment variable with its value set to the corresponding store path.
    outputs = [ "out" ];
    system = builtins.currentSystem;
    PATH = pkgs.lib.makeBinPath (with pkgs; [ coreutils gcc ]);
  };
in
"${builtins.readFile drv} world"

# Debugging
# nix show-derivation <path>
