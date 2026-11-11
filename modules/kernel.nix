{ config, pkgs, lib, isLaptop, nixtamal, functions, ... }:

{
  boot.kernelParams = [
    "sysrq_always_enabled=1"
    "mitigations=off"
    "plymouth.use-simpledrm"
    "preempt=full"
    "split_lock_detect=off"
    "amd_pstate=active"
    "transparent_hugepage=always"
    #"lockdown=integrity" # Needed by EAC v2
    "amd_iommu=on" # No passthrough (same reason)
    "amdgpu.exp_hw_support=1"
    "i915.enable_guc=3"
    "pci=assign-busses,hpbussize=0x33,realloc=on"
    "kvm.enable_virt_at_load=0"
    "amdgpu.dc=1"
    "vfio-pci.disable_vga=1"
  ] ++ lib.optionals (!isLaptop) [
    "nohz_full=1-N"
  ];

  powerManagement.cpuFreqGovernor = if isLaptop then "schedutil" else "performance";

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    shrinkerEnabled = true;
  };

  catppuccin.tty.enable = !isLaptop;

  hardware = {
    amdgpu = {
      overdrive = {
        enable = true;
        ppfeaturemask = lib.mkIf isLaptop "0xffffffff"; # Enables GFXOFF & stutter mode power saving features
      };
      opencl.enable = true;
      zluda.enable = true;
    };

    nvidia.open = true;
    nvidia.branch = "bleeding_edge";

    enableAllFirmware = true;

    new-lg4ff.enable = true;
    xpadneo.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

  specialisation = let
    variant = pkg: { configuration.boot.kernelPackages = lib.mkOverride 49 pkg; };
  in {
    stock_kernel = variant pkgs.linuxPackages_latest;
  };

  boot.kernelPatches = [ ];

  boot.extraModulePackages = [];

  boot.kernelModules = [];

  boot.blacklistedKernelModules = [];

  services.scx-loader = { # https://wiki.cachyos.org/configuration/sched-ext/#general-recommendations
    enable = false;
    config = {
      default_sched = "scx_lavd";
      default_mode = if isLaptop then "Auto" else "Gaming";
    };
  };

  boot.kernel.sysctl = {
    #"vm.swappiness" = 30; # Already set by cachyos settings
    "vm.max_map_count" = 16777216;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake"; # / "cake_mq"
  };

  programs.obs-studio = {
    package = null; enable = true; # Installed & configured via home manager instead
    enableVirtualCamera = true;
  };

  boot.kexec.enable = false; # EAC v2 wants it to be disabled at boot time
}
