{ pkgs, lib, isLaptop, nixtamal, ... }:

{
  imports = [ (import nixtamal.qylock).outputs.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # SDDM theme setup
  catppuccin.sddm.enable = false;
  programs.qylock = {
    enable = true;
    theme = "Genshin";
    themeOptions = {
      Genshin.backgroundMode = "time";
    };
  };

  qt.enable = true;

  environment.systemPackages = with pkgs; [
    uwsm
    app2unit
    rofi
    murale
    awww
    cliphist
    wl-clipboard
    hyprshot
    nwg-look
    hyprsunset
    hyprpolkitagent
    pwvucontrol
    playerctl
    ironbar
    swaybg
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    papirus-icon-theme
    (magnetic-catppuccin-gtk.override {
      accent = [ "all" ];
      size   = "standard"; #"compact"
      shade  = "dark";
      tweaks = [ ] ++ lib.optional (isLaptop) "black";
    })
    xeyes
    networkmanagerapplet
  ];
}
