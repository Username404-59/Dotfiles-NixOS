{ config, ...}:

{
  boot.extraModulePackages = with config.boot.kernelPackages; [];

  boot.kernelModules = [];

  boot.blacklistedKernelModules = [];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger.turbo = "auto";
      battery.turbo = "never";
    };
  };

  services.upower.enable = true;

  # Thunderbolt automatic authorization etc
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.branch = "bleeding-edge";

  networking.hostName = "lizard-portable";
}
