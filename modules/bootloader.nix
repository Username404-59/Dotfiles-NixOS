{ pkgs, lib, config, nixtamal, ... }:

let
  lanzaboote = import nixtamal.lanzaboote { inherit pkgs; };
in
{
  imports = [ lanzaboote.nixosModules.lanzaboote ];

  system.nixos-init.enable = true; # Note: doesn't run system.activationScripts as of writing

  # Bootloader.
  boot = {
    lanzaboote = { # TODO Replace lanzaboot with upstream stuff when secureboot is in nixpkgs (e.g microsoft shim)
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
      autoEnrollKeys.autoReboot = false;
    };

    loader = {
      grub.enable = false;
      systemd-boot.enable = lib.mkForce (!config.boot.lanzaboote.enable); # Has to be disabled for lanzaboote (as of writing)

      efi.canTouchEfiVariables = true;

      # 0 = Hide the OS choice for bootloaders.
      # It would still be possible to open the bootloader list by pressing any key
      # It just would not appear on screen unless a key is pressed
      timeout = lib.mkForce 3; # Forced, else it doesn't work when making an ISO
    };

    initrd.systemd.emergencyAccess = lib.mkDefault config.users.users."doggo".hashedPassword;

    # Enables "Silent boot"
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
