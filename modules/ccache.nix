{ config, ... }:

{
  programs.ccache = {
    enable = true;
    packageNames = [
      # Packages here
      "mesa"
      "pkgsi686Linux.mesa"
    ];
  };

  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
}