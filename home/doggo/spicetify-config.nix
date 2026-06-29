{ spicetify-nix, ... }:

{
  programs.spicetify = {
    enable = true;

    theme = spicetify-nix.packages.themes.catppuccin;
    colorScheme = "mocha";
    enabledExtensions = with spicetify-nix.packages.extensions; [];
    enabledCustomApps = with spicetify-nix.packages.apps; [];
  };
}