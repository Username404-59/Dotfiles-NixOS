{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;
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
      tweaks = [ /*black*/ ];
    })
    xeyes
    networkmanagerapplet
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
