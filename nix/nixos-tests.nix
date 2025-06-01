# https://nix.dev/tutorials/nixos/integration-testing-using-virtual-machines#introduction
# https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
# https://nixos.org/manual/nixos/stable/index.html#sec-nixos-test-nodes
#
# nix-build nixos-tests.nix
# nix-store --read-log result
#
# https://nixos.org/manual/nixos/stable/index.html#sec-running-nixos-tests-interactively
# interative
# $(nix-build -A driverInteractive nixos-tests.nix)/bin/nixos-test-driver
#   - machine1.start()
#   - machine1.shell_interact()
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  # explicitly set configuration options and overlays to avoid them being inadvertently overridden by global configuration
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in

pkgs.testers.runNixOSTest {
  # https://nixos.org/manual/nixos/stable/index.html#sec-test-options-reference
  name = "test-package-exists-for-user";

  # allow ssh to the vms
  # This creates a vsock socket for each VM to log in with SSH. This configures root login with an empty password.
  # machine1: ssh vsock/3 -o User=root
  # machine2: ssh vsock/4 -o User=root
  # The socket numbers correspond to the node number of the test VM, but start at three instead of one because that’s the lowest possible vsock number. The exact SSH commands are also printed out when starting nixos-test-driver.
  interactive.sshBackdoor.enable = true;

  nodes = {
    # NixOS module - https://nixos.org/manual/nixos/stable/#sec-writing-modules
    machine1 = { pkgs, ... }: {
      users.users.alice = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = with pkgs; [
          firefox
        ];
      };

      system.stateVersion = "25.05";
    };
    machine2 = import ./vm-config/configuration.nix;
  };

  # example tests - https://github.com/NixOS/nixpkgs/tree/master/nixos/tests
  # functions - https://nixos.org/manual/nixos/stable/index.html#ssec-machine-objects
  # adding extra python packages - https://nixos.org/manual/nixos/stable/index.html#ssec-python-packages-in-test-script
  testScript = _: ''
    machine1.wait_for_unit("default.target")
    machine1.succeed("su -- alice -c 'which firefox'")
    machine1.fail("su -- root -c 'which firefox'")
  '';
}
