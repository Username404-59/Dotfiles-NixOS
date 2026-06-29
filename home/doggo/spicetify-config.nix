{ spicetify-nix, ... }:

{
  programs.spicetify = {
    enable = true;

    theme = spicetify-nix.packages.themes.catppuccin; # TODO: Use https://github.com/0lswitcher/spotneotify
    colorScheme = "mocha";
    enabledExtensions = with spicetify-nix.packages.extensions; [];
    enabledCustomApps = with spicetify-nix.packages.apps; [];
  };
}