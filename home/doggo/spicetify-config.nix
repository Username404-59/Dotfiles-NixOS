{ nixtamal, ... }:

let
  spicetify-nix = import nixtamal.nix-spicetify { pkgs = import nixtamal.nixpkgs { }; };
in
{
  imports = [ spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;

    theme = {
      name = "spotneotify";
      src = nixtamal.spotneotify;
      injectCss      = true;
      replaceColors  = true;
      injectThemeJs  = false;
      overwriteAssets = false;
    };
    colorScheme = "CatppuccinMocha";

    enabledExtensions = with spicetify-nix.packages.extensions; [];
    enabledCustomApps = with spicetify-nix.packages.apps; [];
  };
}