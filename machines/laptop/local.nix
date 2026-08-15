{ config, ...}:

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

  # NVIDIA drivers and DisplayLink support
  # TODO Apply the cachyos nvidia patches for compatibility with -rc kernels
  services.xserver.videoDrivers = [ /*"nvidia"*/ "displaylink" ];
  #hardware.nvidia.open = true;
  #hardware.nvidia.branch = "bleeding_edge";

  networking.hostName = "lizard-portable";
}
