{ config, lib, functions, nixtamal, ... }:

/*
  This should be in /etc/nixos/.

  To install git before first install:
  sudo nix-env --install git

  To rebuild for the first time:
  sudo nixos-rebuild switch --option extra-experimental-features "blake3-hashes auto-allocate-uids"

  To force nixtamal lock on specific input:
  sudo nixtamal lock --force specific_input

  To make an ISO: (https://nixos.org/manual/nixos/stable/#sec-image-nixos-rebuild-build-image)
  sudo nixos-rebuild build-image --image-variant iso-installer

  To make a clean update:
  tput reset && sudo su - root
  nix-collect-garbage && nix-collect-garbage -d && nixos-rebuild switch
*/
let
  # self = final package set, super = pre-overlay nixpkgs
  # super.lib: avoids circular dependencies
  # self.callPackage: local packages can see each other and other overlays
  localPackagesOverlay = self: super: super.lib.packagesFromDirectoryRecursive {
    callPackage = self.callPackage;
    directory   = ./local_packages;
  };

  pkgs = import nixtamal.nixpkgs {
    config.allowUnfree = true;
    overlays = with nixtamal; [
      # CachyOS kernels repo
      (import nix-cachyos-kernel).overlays.default
      # Nix-gaming overlay (for low_latency_layer)
      (import nix-gaming).overlays.default
      # Nix-Citizen tools overlay (for dw-proton-bin notably)
      (import nix-citizen).overlays.steamcompattools
      # AMD AI overlay
      (import nix-amd-ai).overlays.default
      # Local packages
      localPackagesOverlay
    ];
  };

  isLaptop =
    let
      powerSupplyDir = /sys/class/power_supply;
    in
      builtins.pathExists powerSupplyDir && lib.any (name: lib.hasPrefix "BAT" name) (builtins.attrNames (builtins.readDir powerSupplyDir));
in
{
  nixpkgs.pkgs = pkgs; # Uses the nixtamal nixpkgs
  _module.args.isLaptop = isLaptop;

  imports =
    [
      ./workarounds.nix
      ./hardware-configuration.nix # Results of the hardware scan ("nixos-generate-config" command; Note: I have to remove swapDevices from there and put "swap" partlabel on the partition)
      ./modules/filesystems.nix
      "${nixtamal.home-manager}/nixos"
      "${nixtamal.catppuccin}/modules/nixos"
      "${nixtamal.nix-cachyos-settings}/module.nix"
      ./modules/bootloader.nix
      ./modules/encryption.nix
      ./modules/system-packages.nix
      ./modules/security.nix
      ./modules/fonts.nix
      ./modules/hyprland.nix
      ./modules/kernel.nix
      ./modules/ccache.nix
      ./modules/networking.nix
      ./modules/mesa.nix
      ./modules/audio.nix
      ./modules/ananicy.nix
      ./modules/printing.nix

      ./common/ollama-config.nix
      ./common/amd-ai-config.nix
      ./common/neovim-config.nix

      ./machines/${
        if isLaptop then "laptop" else "desktop"
      }/local.nix

      # ISO installer building stuff:
      ./ISO/iso.nix
    ];

  home-manager.useUserPackages = true; # Puts user packages in /etc/profiles
  home-manager.useGlobalPkgs = false; # Home-manager inherits the pkgs path since NixOS 20.09 (unlike what the docs seem to say), meaning it uses my pinned nixpkgs source already
  nix.package = pkgs.nixVersions.latest;
  nix.channel.enable = false; # Channels are not needed / useless with nixtamal
  nix.nixPath = [ "nixpkgs=${nixtamal.nixpkgs}" ]; # Fixes <nixpkgs> (which nixtamal uses for some reason when fetching patches as of writing)
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "blake3-hashes" "auto-allocate-uids" ]; # blake3 is for nixtamal. https://nix.dev/manual/nix/stable/development/experimental-features
    auto-allocate-uids = true;
  };

  catppuccin = {
    autoEnable = true;
    enable = true;
    accent = "red";
    flavor = "mocha";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."doggo" = {
    isNormalUser = true;
    description = "Charlie Quinet";
    extraGroups = [ "networkmanager" "wheel" "networkmanager" "video" "input" "audio" "kvm" "uinput" ];
  };

  home-manager.extraSpecialArgs = {
    inherit nixtamal localPackagesOverlay isLaptop;
  };
  home-manager.users.doggo = import ./home/doggo/doggo.nix;

  cachyos.settings = {
    enable = true;
    zram.enable = false;
    debuginfod.enable = false;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = true;
      PermitRootLogin = "prohibit-password";
    };
  };

  # To disable the firewall altogether.
  # networking.firewall.enable = false;

  # Replaces /bin/sh with dash (which is faster than bash)
  environment.binsh = "${
    (functions.mkWithCFlags pkgs.dash "-Ofast -flto -fwhole-program -fno-unroll-loops")
  }/bin/dash";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # Did you read the comment?
}
