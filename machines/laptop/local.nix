{ config, lib, pkgs, ...}:

{
  boot.extraModulePackages = with config.boot.kernelPackages; [];

  boot.kernelModules = [];

  boot.blacklistedKernelModules = [];

  services.power-profiles-daemon.enable = true;

  services.upower.enable = true;

  # Thunderbolt automatic authorization etc
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  # TODO: Remove this if my laptop & desktop ever end up having the same microarchitecture
  boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;

  # NVIDIA drivers
  # TODO Apply the cachyos nvidia patches for compatibility with -rc kernels
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.open = true;
  #hardware.nvidia.branch = "bleeding_edge";

  networking.hostName = "lizard-portable";
}
