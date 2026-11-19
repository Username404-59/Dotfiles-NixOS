{ config, pkgs, lib, ... }:

{
  boot.kernelParams = [
    "sysrq_always_enabled=1"
    "mitigations=off"
    "split_lock_detect=off"
  ];

  powerManagement.cpuFreqGovernor = "performance";

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    shrinkerEnabled = true;
  };

  boot.kernel.sysfs.boot.kernel.mm.transparent_hugepage = {
    enabled = "always";
    defrag = "defer+madvise";
    shmem_enabled = "within_size";
  };

  hardware = {
    enableAllFirmware = true;
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;

  specialisation = let
    variant = pkg: { configuration.boot.kernelPackages = lib.mkOverride 49 pkg; };
  in {
    stock_kernel = variant pkgs.linuxPackages_latest;
  };

  boot.kernelPatches = [ ];

  boot.extraModulePackages = [];

  boot.kernelModules = [];

  boot.blacklistedKernelModules = [];

  boot.kernel.sysctl = {
    #"vm.swappiness" = 30; # Already set by cachyos settings
    "vm.max_map_count" = 16777216;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake"; # / "cake_mq"
  };
}
