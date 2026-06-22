{ config, lib, ... }:

# This should be in /etc/nixos/ together with the rest.

# For the nixos channel
# nix-channel --add https://channels.nixos.org/nixos-unstable nixos && nix-channel --update

# To fix problems sometimes:
# sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix

let
  nixtamal = import ./tamal {
    bootstrap-nixpkgs = <nixpkgs>; # Apparently a little bit impure but faster. (can be removed)
  };

  # self = final package set, super = pre-overlay nixpkgs
  # super.lib: avoids circular dependencies
  # self.callPackage: local packages can see each other and other overlays
  localPackagesOverlay = self: super: super.lib.packagesFromDirectoryRecursive {
    callPackage = self.callPackage;
    directory   = ./local_packages;
  };

  pkgs = import nixtamal.nixpkgs {
    config.allowUnfree = true;
    overlays = [
      # CachyOS kernels repo
      (import nixtamal.nix-cachyos-kernel).overlays.default
      # Nix-Citizen tools overlay (for dw-proton-bin notably)
      (import nixtamal.nix-citizen).overlays.steamcompattools
      # Local packages
      localPackagesOverlay
    ];
  };
in
{
  nixpkgs.pkgs = pkgs; # Uses the nixtamal nixpkgs
  _module.args.nixtamal = nixtamal;

  imports =
    [
      ./local.nix
      ./hardware-configuration.nix # Results of the hardware scan ("nixos-generate-config" command)
      "${nixtamal.home-manager}/nixos"
      "${nixtamal.catppuccin}/modules/nixos"
      "${nixtamal.nix-cachyos-settings}/module.nix"
      ./bootloader.nix
      ./modules/system-packages.nix
      ./modules/fonts.nix
      ./modules/hyprland.nix
      ./modules/kernel.nix
      ./modules/ccache.nix
      ./modules/networking.nix
      ./modules/mesa.nix
    ];
  
  home-manager.useUserPackages = true; # Puts user packages in /etc/profiles
  home-manager.useGlobalPkgs = false; # Home-manager inherits the pkgs path since NixOS 20.09 (unlike what the docs seem to say), meaning it uses my pinned nixpkgs source already
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "blake3-hashes" ]; # blake3 is for nixtamal

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
    extraGroups = [ "networkmanager" "wheel" "networkmanager" "video" "input" "audio" "kvm" ];
  };

  home-manager.extraSpecialArgs = {
    inherit nixtamal;
  };
  home-manager.users.doggo = import ./home/doggo/doggo.nix;

  security.polkit.enable = true;

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

  # Extra security (especially for SSH)
  services.fail2ban.enable = true;

  # To disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # Did you read the comment?
}
