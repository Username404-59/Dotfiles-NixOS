{ nixtamal, pkgs, config, ... }:

let
  mkBundleFromNixtamal = name: {
    appId = "com.hypixel.HytaleLauncher";
    bundle = "${nixtamal.${name}}";
    sha256 = nixtamal.${name}.hash;
  };
  runtime_version = "${pkgs.stdenv.hostPlatform.parsed.cpu.name}/25.08";

  roblox_config_path = "%h/.var/app/org.vinegarhq.Sober/data/sober/appData/GlobalBasicSettings_13.xml";
in
{
  imports = [ "${nixtamal.nix-flatpak}/modules/home-manager.nix" ];

  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    update.onActivation = true;

    remotes = [
      { name = "flathub";      location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
      { name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo"; }
    ];
    packages = [
      # Drivers
      { appId = "runtime/org.freedesktop.Platform.GL.mesa-git/${runtime_version}";   origin = "flathub-beta"; }
      { appId = "runtime/org.freedesktop.Platform.GL32.mesa-git/${runtime_version}"; origin = "flathub-beta"; }

      # Gaming stuff
      "org.vinegarhq.Sober"
      (mkBundleFromNixtamal "hytale-launcher")
      "moe.launcher.an-anime-game-launcher"
      "moe.launcher.the-honkers-railway-launcher"
      "runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/${runtime_version}"

      # Apps
      #"com.github.tchx84.Flatseal" # I should put overrides in this .nix instead
      "com.gluonhq.SceneBuilder"
    ];

    overrides.writeMode = "replace";

    overrides.settings = {
      global = {
        Context.filesystems = [
          "/nix/store:ro"
          "xdg-config/MangoHud:ro"
          # Theming
          "${config.home.homeDirectory}/.icons:ro"
          "${config.home.homeDirectory}/.themes:ro"
          "xdg-config/fontconfig:ro"
          "xdg-config/gtkrc:ro"
          "xdg-config/gtkrc-2.0:ro"
          "xdg-config/gtk-2.0:ro"
          "xdg-config/gtk-3.0:ro"
          "xdg-config/gtk-4.0:ro"
          "xdg-data/fonts:ro"
          "xdg-data/themes:ro"
          "xdg-data/icons:ro"
        ];
        Environment = {
          MANGOHUD = "1";
          GTK_THEME = config.home.sessionVariables.GTK_THEME;
        };
        Context.sockets = [ "wayland" ];
      };

      "org.vinegarhq.Sober".Context = {
        filesystems = [
          "xdg-run/app/com.discordapp.Discord:create"
          "xdg-run/discord-ipc-0"
        ];
        features = [ "all-syscalls" ]; # requires the 5224_all_syscalls flatpak patch I modified -> little performance boost (in theory)
      };

      "com.hypixel.HytaleLauncher".Context.features = [ "all-syscalls" ];
      "moe.launcher.an-anime-game-launcher".Context.features = [ "all-syscalls" ];
      "moe.launcher.the-honkers-railway-launcher".Context.features = [ "all-syscalls" ];
    };
  };

  systemd.user.services.unlock-roblox-framerate-cap = {
    Unit.Description = "Force Roblox FramerateCap to 9999";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.gnused}/bin/sed -i -E 's@<int name=\"FramerateCap\">[0-9]+</int>@<int name=\"FramerateCap\">9999</int>@' ${roblox_config_path}";
    };
  };

  systemd.user.paths.unlock-roblox-framerate-cap = {
    Unit.Description = "Watches the roblox config file to forcefully unlock fps";
    Path.PathModified = "${roblox_config_path}";
    Install.WantedBy = [ "default.target" ];
  };

  home.sessionVariables.FLATPAK_GL_DRIVERS = "mesa-git";
}