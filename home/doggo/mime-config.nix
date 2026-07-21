{ config, ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [
      config.programs.firefox.package
    ];
    defaultApplications = {
      "application/pdf" = "${config.programs.firefox.package.pname}.desktop";
      "x-scheme-handler/jetbrains" = "jetbrainsd.desktop";
    };
  };
}