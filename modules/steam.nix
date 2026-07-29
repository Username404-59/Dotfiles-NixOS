{ pkgs, functions, isLaptop, config, lib, ... }:

let
  steam_env = {
    MANGOHUD = "1";
    OBS_VKCAPTURE = "1";
    MESA_VK_WSI_PRESENT_MODE = if (!isLaptop) then "immediate" else "mailbox"; # Enables tearing (which is fixed by VRR, which my laptop's screen doesn't have)

    # Environment variables for dw-proton-bin (https://dawn.wine/dawn-winery/dwproton)
    PROTON_DXVK_LLASYNC = "1";
    PROTON_VKD3D_LOWLATENCY = "1";
    PROTON_USE_WINEALSA = "1";
  };
in
{
  programs.steam = {
    enable = true;
    extest.enable = true; # Makes Steam Input work on wayland
    dedicatedServer.openFirewall = true; # 27015 port
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      dw-proton-bin # From nix-citizen overlay
    ];
    extraPackages = with pkgs; [
      (functions.mkUnstable lsfg-vk)
    ];
    package = pkgs.steam.override {
      extraEnv = steam_env;
    };
    # Note: to make another disk visible to games add
    # STEAM_COMPAT_MOUNTS=/disk2 %command%
    # to commandline options
  };

  home-manager.extraSpecialArgs.steam_env = steam_env;

  programs.gamescope = {
    enable = true;
    capSysNice = false; # Has issues in steam/steam-run
  };
}