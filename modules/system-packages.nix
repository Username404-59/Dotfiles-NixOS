{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
    fastfetch
    htop
    killall
    file
    e2fsprogs
    cpu-x
    lact
    steam-run
    exfatprogs
    nixtamal # Important
    android-tools
    kdePackages.kleopatra # Needed to add keys easily
    nload
    graalvmPackages.graalvm-ce # Java
    clang gcc mold
    cmake
    sbctl # For secure boot with Limine
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      dw-proton-bin # From nix-citizen overlay
    ];
    # Note: to make another disk visible to games add
    # STEAM_COMPAT_MOUNTS=/disk2 %command%
    # to commandline options
  };

  services.flatpak.enable = true;

  services.lact.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  programs.partition-manager.enable = true;

  environment.sessionVariables = rec {
    NIXTAMAL_DIRECTORY = "tamal";
  };

  environment.shellAliases = {
    nixtamal = "bash -c 'cd /etc/nixos && nixtamal \"$@\"' --";
  };
}
