{ config, pkgs, nixtamal, ... }:

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
      package = pkgs.magnetic-catppuccin-gtk;
    };
  };

  home.sessionVariables.GTK_THEME = shared_theme;

  # Editor → Editor Settings → Text Editor → Theme
  xdg.configFile."godot/text_editor_themes/Catppuccin Mocha.tet".source = nixtamal.catppuccin-godot; # Godot editor theme

  # Editor → Editor Settings → Interface → Theme
  # Godot interface colors:
  # Base Color: #1e1e2e
  # Accent: #cba6f7
  # Contrast: 0.2
  # Icon Saturation: 0.6
}
