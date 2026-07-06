{ nixtamal, pkgs, ... }:

let
  mkBundleFromNixtamal = name: {
    appId = "com.hypixel.HytaleLauncher";
    bundle = "${nixtamal.${name}}";
    sha256 = nixtamal.${name}.hash;
  };
  runtime_version = "25.08";
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
      { appId = "runtime/org.freedesktop.Platform.GL.mesa-git/${pkgs.stdenv.hostPlatform.parsed.cpu.name}/${runtime_version}";   origin = "flathub-beta"; }
      { appId = "runtime/org.freedesktop.Platform.GL32.mesa-git/${pkgs.stdenv.hostPlatform.parsed.cpu.name}/${runtime_version}"; origin = "flathub-beta"; }

      # Games
      "org.vinegarhq.Sober"
      (mkBundleFromNixtamal "hytale-launcher")
      "moe.launcher.an-anime-game-launcher"
      "moe.launcher.the-honkers-railway-launcher"

      # Apps
      #"com.github.tchx84.Flatseal" # I should put overrides in this .nix instead
      "com.gluonhq.SceneBuilder"
    ];

    overrides.settings = {
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

  home.sessionVariables.FLATPAK_GL_DRIVERS = "mesa-git";
}