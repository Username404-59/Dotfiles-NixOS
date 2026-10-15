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

  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    allowExternalGpu = true;
    # To find the bus IDs: lspci -D
    amdgpuBusId = "PCI:69@0:0:0";
    nvidiaBusId = "PCI:38@0:0:0";
  };

  networking.hostName = "lizard-portable";
}
