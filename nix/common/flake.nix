{
  description = "Personal nix flake for common functions";

  outputs = { self }: {
    lib = {
      sayHello = name: "Hello there, ${name}!";
    };
  };
}
