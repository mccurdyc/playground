# Nix Modules

Before we try to understand flake-parts, we must understand the inner-workings of modules.

[The magic of modules is entirely defined in `evalModules`](https://github.com/NixOS/nixpkgs/blob/2b10a50ae3da5b008025eefa9a440d95559bccde/lib/modules.nix#L84) i.e., the merging of `options` into `config`.

`<nixpkgs>.lib.evalModules` - https://nixos.org/manual/nixpkgs/stable/#module-system-lib-evalModules

# flake-parts

Declare options; produce configs.

Defines a reusable module-passing pattern, similar to `nixosModules` or `darwinModules`. These modules
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
