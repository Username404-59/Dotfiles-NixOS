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

        extensions.settings = {
          "uBlock0@raymondhill.net".settings = {
            selectedFilterLists = [ # https://github.com/gorhill/uBlock/blob/master/assets/assets.json
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
              "ublock-experimental"
              "easylist" "easyprivacy"

              # Filter lists for cookie notices:
              "adguard-cookies"
              "ublock-cookies-adguard"
              "fanboy-cookiemonster"
              "ublock-cookies-easylist"

              # Annoyances
              "ublock-annoyances"
              "adguard-popup-overlays"
              "adguard-mobile-app-banners"
              "adguard-other-annoyances"
              "adguard-widgets"
              "easylist-annoyances"
              "easylist-chat"
              "fanboy-ai-suggestions"
              "easylist-newsletters"
              "easylist-notifications"
            ];
          };
        };
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
        "browser.aboutConfig.showWarning" = lock-false;

        # Performance etc
        "gfx.webrender.all" = lock-true;
        "layers.gpu-process.force-enabled" = lock-true;
        "network.trr.mode" = 2; # Uses DNS over HTTPS which can maybe make my page loads faster
      };

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  services.psd.enable = true; # Firefox in RAM, because why not
}
