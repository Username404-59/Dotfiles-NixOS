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

      # Apps
      #"com.github.tchx84.Flatseal" # I should put overrides in this .nix instead
      "com.gluonhq.SceneBuilder"
    ];
  };

  home.sessionVariables.FLATPAK_GL_DRIVERS = "mesa-git";
}