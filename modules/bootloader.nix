{ pkgs, lib, ... }:

{
  catppuccin.plymouth.enable = false;

  # Bootloader.
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      limine.enable = true;

      limine.secureBoot = {
        enable = true;
        autoEnrollKeys.enable = true;
      };

      efi.canTouchEfiVariables = true;

      # 0 = Hide the OS choice for bootloaders.
      # It would still be possible to open the bootloader list by pressing any key
      # It just would not appear on screen unless a key is pressed
      timeout = lib.mkForce 5; # Forced, else it doesn't work when making an ISO
    };

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
