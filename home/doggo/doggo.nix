{ config, pkgs, nixtamal, functions, localPackagesOverlay, ... }:

let
  spicetify-nix = import nixtamal.nix-spicetify { pkgs = import nixtamal.nixpkgs { }; };
in
{
  home.username = "doggo";
  home.homeDirectory = "/home/doggo";
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop     = "${config.home.homeDirectory}/Bureau";
    documents   = "${config.home.homeDirectory}/Documents";
    download    = "${config.home.homeDirectory}/Téléchargements";
    music       = "${config.home.homeDirectory}/Musique";
    pictures    = "${config.home.homeDirectory}/Images";
    videos      = "${config.home.homeDirectory}/Vidéos";
    templates   = "${config.home.homeDirectory}/Modèles";
    publicShare = "${config.home.homeDirectory}/Public";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;
  nixpkgs.overlays = [
    (import nixtamal.dolphin-overlay)
    (import nixtamal.nix-citizen).overlays.default
    localPackagesOverlay
  ];

  home.packages = with pkgs; [
    kdePackages.kate
    (discord-canary.override {
      withOpenASAR = true;
      withEquicord = true;
    })
    #orbolay # Hud overlay for equicord (https://github.com/Equicord/Equicord/blob/main/src/equicordplugins/orbolayBridge/index.tsx)
    kdePackages.qtsvg # Needed for icons in KDE Dolphin
    kdePackages.dolphin
    kdePackages.ark zip unzip
    kdePackages.kio # For network shares
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.gwenview
    kdePackages.filelight
    kdePackages.kdenlive
    qalculate-qt
    mission-center
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi
        obs-gstreamer
        obs-vkcapture
      ];
    })
    (functions.mkUnstable ani-cli)
    anime4k
    yt-dlp
    jetbrains.idea
    jetbrains.clion
    #androidStudioPackages.canary.full
    #androidStudioForPlatformPackages.canary # Android studio but better for AOSP dev
    #git-repo # Android dev tool
    lmms-full
    gnome-feeds
    vulkan-tools mesa-demos # vkcube & glxgears
    #spotifywm # Lets me make a hyprland window rule for spotify. Currently commented out because spicetify pulls it.

    # Gaming packages:
    (prismlauncher.override {
      jdks = [
        graalvmPackages.graalvm-ce
        pkgs.jdk25
        pkgs.jdk21
      ];
    })
    rsi-launcher-git
    osu-lazer-bin
    godot
    wowup-cf
  ];

  imports = [
    "${nixtamal.catppuccin}/modules/home-manager"
    ./catppuccin-config.nix
    ./hyprland-config.nix
    ./ironbar-config.nix
    ./rofi-config.nix
    ./kitty-config.nix
    ./discord-config.nix
    ./firefox-config.nix
    ./mpv-config.nix
    spicetify-nix.homeManagerModules.spicetify
    ./spicetify-config.nix
  ];
  _module.args = { inherit spicetify-nix; };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  programs.bash.enable = true; # Needed for session variables
  home.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    
    PROTON_USE_NTSYNC = "1";
    PROTON_ENABLE_WAYLAND = "1";
    DISABLE_LAYER_MESA_ANTI_LAG = "1";
    LOW_LATENCY_LAYER = "1";
    # Note: set LOW_LATENCY_LAYER_REFLEX = "1" for games with nvidia reflex
    # (or some like cyberpunk 2077 where anti-lag 2 is supported but is worse than reflex and/or none)

    # flatpak --user remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
    # flatpak --user install org.freedesktop.Platform.GL.mesa-git
    # flatpak --user install org.freedesktop.Platform.GL32.mesa-git
    FLATPAK_GL_DRIVERS = "mesa-git";

    NIXOS_OZONE_WL = "1"; # Makes electron apps (e.g discord & spotify) use wayland
  };

  programs = {
    mangohud = {
      enable = true;
      settings = {
        gpu_stats = true;
        gpu_temp = true;
        gpu_junction_temp = true;
        gpu_core_clock = true;
        gpu_mem_temp = true;
        gpu_mem_clock = true;
        gpu_power = true;
        gpu_fan = true;
        gpu_voltage = true;
        cpu_stats = true;
        cpu_mhz = true;
        vram = true;
        fps = true;
        frametime = true;
        gpu_name = true;
        vulkan_driver = true;
        wine = true;
        winesync = true;
        frame_timing = true;
        text_outline = true;
      };
    };
  };

  home.stateVersion = "26.11";
}
