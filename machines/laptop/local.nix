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

  networking.hostName = "lizard-portable";
}
