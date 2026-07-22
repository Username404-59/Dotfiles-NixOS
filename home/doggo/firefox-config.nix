{ options, config, pkgs, lib, functions, ... }:

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
    package = functions.wrapWithNoPreload pkgs.firefox-beta;
    enable = true;
    languagePacks = [ "fr" ];
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

          "addon@darkreader.org".settings = {
            enabled = true;
            syncSettings = false;
            theme = {
              mode = 1;
              engine = "dynamicTheme";
              darkSchemeBackgroundColor = "#1e1e2e";  # Catppuccin Mocha background
              darkSchemeTextColor = "#cdd6f4";        # Catppuccin Mocha text
              selectionColor = "#585b70";             # Catppuccin Mocha selection
            };
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
        "media.hardware-video-decoding-vulkan.enabled" = lock-true;
        "media.hardware-video-decoding-vulkan.direct-export.enabled" = lock-true;
        "network.trr.mode" = 2; # Uses DNS over HTTPS which can maybe make my page loads faster
      };

      ExtensionSettings = let
        extension = shortId: uuid: default_area: {
          name = uuid;
          value = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${shortId}/latest.xpi";
            installation_mode = "force_installed";
            default_area = default_area;
            blocked_install_message = "NON.";
          };
        };
      in builtins.listToAttrs [ # Addon IDs: about:debugging#/runtime/this-firefox
        # Essentials
        (extension "ublock-origin" "uBlock0@raymondhill.net" "menupanel")
        (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}" "navbar")
        (extension "darkreader" "addon@darkreader.org" "navbar")
        (extension "imagus" "{00000f2a-7cde-4f20-83ed-434fcb420d71}" "menupanel")
        (extension "uaswitcher" "user-agent-switcher@ninetailed.ninja" "navbar")
        (extension "cookie-editor" "{c3c10168-4186-445c-9c5b-63f12b8e2c87}" "navbar")
        (extension "re-enable-right-click" "{278b0ae0-da9d-4cc6-be81-5aa7f3202672}" "navbar")
        (extension "buster-captcha-solver" "{e58d3966-3d76-4cd9-8552-1582fbc800c1}" "menupanel")

        # Website specific stuff
        (extension "lovely-forks" "github-forks-addon@musicallyut.in" "menupanel")
        (extension "return-youtube-dislikes" "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" "menupanel")
        (extension "ttv-lol-pro" "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}" "navbar")
        (extension "btroblox" "btroblox@antiboomz.com" "menupanel")
        (extension "sponsorblock" "sponsorBlocker@ajay.app" "navbar")

        # Scripting / styling
        (extension "styl-us" "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" "navbar")
        (extension "violentmonkey" "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" "navbar")
        (extension "firefox-color" "FirefoxColor@mozilla.com" "menupanel") # Note: automatically themed by catppuccin

        # Others
        (extension "jetbrains-toolbox" "{bf9e77ee-c405-4dd7-9bed-2f55e448d19a}" "menupanel")
        (extension "10ten-ja-reader" "{59812185-ea92-4cca-8ab7-cfcacee81281}" "menupanel")
        (extension "wayback-machine_new" "wayback_machine@mozilla.org" "navbar")
        (extension "star-citizen-ccu-game" "{878c5814-8eb9-4262-9b4b-f46e74dd7cfa}" "navbar")
      ];
    };
  };

  services.psd.enable = true; # Firefox in RAM, because why not
}
