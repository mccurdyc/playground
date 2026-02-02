# Rust Module

## Flakes

https://nix.dev/concepts/flakes.html

### Flake Output Schema

https://wiki.nixos.org/wiki/Flakes#Output_schema

## https://nix.dev/tutorials/module-system/a-basic-module/

https://nixos.org/manual/nixos/stable/#sec-writing-modules

flake-parts uses an established pattern called "modules".

A nix module takes a specific input attribute set and outputs and arbitrary output attribute set.

This output attribute set likely "plugs in" to the wrapping flake-parts flake. Therefore, these flake-part
modules should define fields that exist in the flake schema.

## `options` - declaring options

Often you'll want to allow some configurability to your module.

https://nixos.org/manual/nixpkgs/stable/#function-library-lib.options.mkOption

### `nixpkgs.lib`

https://nixos.org/manual/nixpkgs/stable/#id-1.4

## `config` - defining values

- https://nix.dev/tutorials/module-system/deep-dive#dependencies-between-options

The `config` argument is not the same as the `config` attribute.

The `config` argument holds the result of the module system’s lazy evaluation, which takes into account
all modules passed to `evalModules` and their `imports`.

In my understanding, this is like Cue, where it's lazy and "flat".

## Option Types

- https://github.com/NixOS/nixpkgs/blob/master/lib/types.nix
- https://nixos.org/manual/nixos/stable/#sec-option-types-basic

## Overlays

https://flake.parts/overlays.html

Patching things.

## Submodules

https://nix.dev/tutorials/module-system/deep-dive#the-submodule-type

Interesting. I don't know that I can think of a use-case yet.

## Using devenv as an abstraction on top of flake-parts for less-nixy folks?

https://flake.parts/options/devenv.html

## Inspiration

- https://github.com/ipetkov/crane
- https://github.com/juspay/rust-flake/tree/main
