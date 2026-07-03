{ config, ...}:

{
  boot.extraModulePackages = with config.boot.kernelPackages; [];

  boot.kernelModules = [];

  boot.blacklistedKernelModules = [];

  powerManagement.cpuFreqGovernor = "schedutil";

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

  networking.hostName = "lizard-portable";
}
