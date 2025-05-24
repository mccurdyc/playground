# nix

## Getting Started

- https://nix.dev/tutorials/nix-language.html

###  `nixpkgs.lib`

- https://nixos.org/manual/nixpkgs/stable/#id-1.4
- https://github.com/NixOS/nixpkgs/blob/master/lib/default.nix

### Commands

#### Collect Garbage

```bash
nix-collect-garbage --delete-old
```

#### System Info

```bash
nix-shell -p nix-info --run "nix-info -m"
```

#### Show flake attributes

```bash
nix flake show '.#'
```

### Flakes in a repl

```bash
nix repl
nix-repl> :lf .#
nix-repl> :p outputs
```

### nix repl with nixpkgs

```bash
nix repl --file '<nixpkgs>'
nix-repl> :b pkgs.ripgrep

This derivation produced the following outputs:
  out -> /nix/store/a84fwx8fsxla5a8naw3p32rfhimdnq7q-ripgrep-14.1.1

nix-repl> :p pkgs.ripgrep.builder
/nix/store/8vpg72ik2kgxfj05lc56hkqrdrfl8xi9-bash-5.2p37/bin/bash
nix-repl> :?

# build logs for derivation
nix-repl> :log pkgs.ripgrep
```

### nix shell

```bash
# https://lazamar.co.uk/nix-versions/
# https://lazamar.co.uk/nix-versions/?package=k3d&version=0.8.0.2&fullName=k3d-0.8.0.2&keyName=k3d&revision=babcd70c36d0c2e2cb000eb3085aa7a42104a4ba&channel=nixpkgs-unstable#instructions

nix shell 'github:nixos/nixpkgs/nixos-25.05#k3d'
nix shell github:nixos/nixpkgs/babcd70c36d0c2e2cb000eb3085aa7a42104a4ba#k3d
nix shell github:nixos/nixpkgs/nixos-unstable#k3d

## Notes

- https://zero-to-nix.com/concepts/flakes/
    - Flakes replace channels
    - A Nix flake is a directory with a flake.nix and flake.lock
    - Flakes thus form a kind of chain


## Exercises

### simple-print

```bash
nix-instantiate --eval simple-print.nix
```

### derivation

```bash
nix-instantiate --eval derivation.nix
```

### flake

```bash
nix run
nix run '.#default'
```
