# Usage: nix-instantiate --strict --eval simple-print.nix
#
# https://www.zombiezen.com/blog/2021/12/nix-from-the-ground-up/
# https://nix.dev/manual/nix/2.24/language/index.html
# https://nix.dev/manual/nix/2.24/language/builtins.html#builtins-builtins
# https://nix.dev/tutorials/nix-language.html

let
  pkgs = import <nixpkgs> { };

  a = 2 + 2;
  inc = x: x + 1;

  add = x: y: x + y;
  addSet = { x, y }: x + y;
  optionalArg = { x, y ? 100 }: x + y;

  # https://nix.dev/manual/nix/2.24/language/builtins.html#builtins-trace
  debug1 = pkgs.lib.debug.traceValFn (v: "value of a: ${toString v}") a;
  debug2 = builtins.trace a a;
in
{
  inherit debug1 debug2;
  three = inc 2;
  add = add 1 3;
  addSet = addSet { x = 1; y = 3; };
  optionalArg = optionalArg { x = 1; };
  optionalArgFilled = optionalArg { x = 1; y = 2; };
}
