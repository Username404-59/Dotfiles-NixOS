{ config, pkgs, nixtamal, lib, isLaptop, ... }:

let
  shared_theme = "Catppuccin-GTK-Red-Dark";
in
{
  imports = [ "${nixtamal.catppuccin}/modules/home-manager" ];

  catppuccin = {
    autoEnable = true;
    enable = true;
    flavor = "mocha";
    accent = "red";
    cursors.enable = true;
    obs.enable = true;
    mangohud.enable = false;
    hyprlock.enable = false; # Default theme is fine, because it's transparent
  };

  home.pointerCursor = {
    enable = true;
    size = 24;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = shared_theme;
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ "all" ];
        size   = "standard"; #"compact"
        shade  = "dark";
        tweaks = [ ] ++ lib.optional (isLaptop) "black";
      };
    };
  };

  home.sessionVariables.GTK_THEME = shared_theme;

  /*
  Editor → Editor Settings → Text Editor → Theme
  Editor → Editor Settings → Interface → Theme
    Godot interface colors:
      - Base Color: #1e1e2e
      - Accent: #cba6f7
      - Contrast: 0.2
      - Icon Saturation: 0.6
  */
  xdg.configFile."godot/text_editor_themes/Catppuccin Mocha.tet".source = nixtamal.catppuccin-godot; # Godot editor theme
}
