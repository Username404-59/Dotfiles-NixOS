{ pkgs, lib, config, nixtamal, ... }:

let
  lanzaboote = import nixtamal.lanzaboote { inherit pkgs; };
in
{
  imports = [ lanzaboote.nixosModules.lanzaboote ];

  catppuccin.plymouth.enable = false;

  system.nixos-init.enable = true; # Note: doesn't run system.activationScripts as of writing

  # Bootloader.
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
      autoEnrollKeys.autoReboot = false; # Better idea to disable this because my fscrypt encryption stuff could be running
      measuredBoot = {
        enable = true;
        pcrs = [ 0 4 7 ];
      };
      configurationLimit = 4; # Needed by measured boot as of writing (TODO: Remove when https://github.com/systemd/systemd/issues/41526#issuecomment-5950825301 is fixed)
    };

    loader = {
      grub.enable = false;
      systemd-boot.enable = lib.mkForce (!config.boot.lanzaboote.enable); # Has to be disabled for lanzaboote (as of writing)

      efi.canTouchEfiVariables = true;

      # 0 = Hide the OS choice for bootloaders.
      # It would still be possible to open the bootloader list by pressing any key
      # It just would not appear on screen unless a key is pressed
      timeout = lib.mkForce 5; # Forced, else it doesn't work when making an ISO
    };

    initrd.systemd.emergencyAccess = config.users.users."doggo".hashedPassword;

    plymouth = {
      enable = true;
      theme = "owl";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "owl" ];
        })
      ];
    };

    # Enables "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
