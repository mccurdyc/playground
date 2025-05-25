{ pkgs, name }: pkgs.writeShellApplication {
  name = "sayHello";
  runtimeInputs = [ pkgs.bash ];
  text = ''
    echo "Hello, ${name}"
  '';
}
