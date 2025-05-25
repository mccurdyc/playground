# nix

## Why Nix?

- 10y cache 
- "sandbox"
- Deterministic and declarative (configuration as code)
- Common build tooling and dependencies manager wrapper for all languages
    - Don't need `package.lock` or `pip`, etc
- Atomic upgrades / rollbacks
    - Just linux symlinks
- Preferring per-project / directory configurations over global packages / configurations

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
nix flake metadata '.#'
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
```

### Dependencies

```bash
nix-store --query --tree /nix/store/<path>.drv
nix-store --query --tree $(nix eval '.#sayHello' --raw)
nix-store --query --tree $(nix path-info --derivation '.#sayHello')

# simple tree
nix-store --query --tree $(nix build '.#sayHello' --no-link --print-out-paths)

# simple dep list
nix-store --query --requisites $(nix build '.#sayHello' --no-link --print-out-paths)

nix why-depends '.#sayHello' <path-path-from-above>

nix why-depends '.#sayHello' /nix/store/cg9s562sa33k78m63njfn1rw47dp9z0i-glibc-2.40-66
warning: Git tree '/home/mccurdyc/src/github.com/mccurdyc/playground' is dirty
/nix/store/m3hzbf5ddzxkidad24k5ms41yzgz4j7m-sayHello
└───/nix/store/1q9lw4r2mbap8rsr8cja46nap6wvrw2p-bash-interactive-5.2p37
    └───/nix/store/cg9s562sa33k78m63njfn1rw47dp9z0i-glibc-2.40-66
```

```bash
nix derivation show '.#sayHello'


nix path-info --derivation '.#packages.x86_64-darwin.sayHello'
/nix/store/85pwpfhzbx9pq19imdrcj0ha1qv2dg9h-sayHello.drv

nix path-info --derivation '.#packages.x86_64-linux.sayHello'
/nix/store/1qj7xzhrkn1335d99gizl424fgz6mpbq-sayHello.drv
```

## Notes

### Flakes

- https://zero-to-nix.com/concepts/flakes/
    - Flakes replace channels
    - A Nix flake is a directory with a flake.nix and flake.lock
    - Flakes thus form a kind of chain
- Flakes are polarizing
	- Why?
	- You don't need flakes
- Cached evaluations!
- Purely a "frontend thing"
	- The daemon doesnt know anything about flakes
	- Derivations are for the daemon

## Exercises

### simple-print

```bash
nix-instantiate --eval simple-print.nix
```

### derivation

```bash
nix-instantiate --eval derivation.nix
```

- `$out` is a nix store path
    - hash of the inputs
- All parameters to your derivation become ENVs in your derivation
	- This is for communicating with your builder function
- Shebangs
	- no `/usr/bin/...` in the nix sandbox
	- `/usr/bin/env xxx` works if `xxx` is part of scripts in the install phase, it automatically patches

### flake

- https://nix.dev/concepts/flakes.html
- Always adhere to this format - https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-flake.html#flake-format

```bash
nix run
nix run '.#default'
nix run 'github:mccurdyc/playground?dir=nix#default'
```

```bash
nix run '.#sayHello -- motloc'
nix run '.#remoteHello'
```
