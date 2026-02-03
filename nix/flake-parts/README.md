# Nix Modules: returns a configured `config` attrset

Before we try to understand flake-parts, we must understand the inner-workings of modules.

[The magic of modules is defined in `evalModules`](https://github.com/NixOS/nixpkgs/blob/2b10a50ae3da5b008025eefa9a440d95559bccde/lib/modules.nix#L84) i.e., the merging of `options` into `config`.

`<nixpkgs>.lib.evalModules` - https://nixos.org/manual/nixpkgs/stable/#module-system-lib-evalModules

In short, `evalModules` relies heavily on the laziness of Nix evaluations as well as a complex merging algorithm that defines
mergable types and priorities. The merging reminded me a bit of Cue at first where we are ultimately normalizing to a single
"flat" object that has `options` and `configs` fields. However, Cue is much stricter and prevents "overrides" where Nix
differs in that it defines an algorithm to handle them.

# flake-parts: A framework to configure flakes via nix modules

Defines a reusable module-sharing pattern, similar to `nixosModules` or `darwinModules`. These modules
are primarily used to define and configure options on a per-system basis, then to be consumed as proper
flake attributes.

This is allowed because there is nothing inherently in nix flakes that validate the output schema.

You can define arbitrary extra fields. `flakeModules` is the established "arbitrary field" used by
flake-parts. Then, it's on the consumer to actually consume these `flakeModules` in such a way that
actually makes sense, such as using it for `devShells` or something.

flake-parts is just a module system evaluator that:

1. Takes modules (with arbitrary options)
2. Evaluates them (merging configs, type-checking, etc.)
3. Returns an attrset

It doesn't care what the options are named - devShells, packages, mccurdyc-rust, banana - all the same to flake-parts.

## `flake-module.nix`: _The_ nix module to configure a flake.

A nix module that defines flake or per-system -level flake attributes?

### `providerInputs`

This prevents consuming flakes from having to explicitly define inputs when instead I could define inputs within the providing flake.
