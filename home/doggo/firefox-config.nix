{ options, config, pkgs, lib, ... }:

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  programs.firefox = {
    configPath = "${config.home.homeDirectory}/.mozilla/firefox";
    package = pkgs.firefox-bin;
    enable = true;
    languagePacks = [ "fr-fr" ];
    profiles = {
      default = {
        id = 0;
        name = "doggo";
        isDefault = true;
        extensions.force = true;
        userChrome = (builtins.readFile ./firefox_css/userChrome.css);
        userContent = (builtins.readFile ./firefox_css/userContent.css);
      };
    };

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      HardwareAcceleration = true;

      Preferences = {
        "extensions.pocket.enabled" = lock-false;
        "dom.security.https_only_mode" = lock-true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
        "browser.tabs.allow_transparent_browser" = lock-true;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "devtools.chrome.enabled" = true;
        "browser.newtabpage.activity-stream.widgets.enabled" = lock-false;

        "gfx.webrender.all" = lock-true;
        "layers.gpu-process.force-enabled" = lock-true;
      };
    };
  };

  services.psd.enable = true; # Firefox in RAM, because why not
}
