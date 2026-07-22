{ config, pkgs, lib, isLaptop, nixtamal, functions, ... }:

{
  boot.kernelParams = [
    "sysrq_always_enabled=1"
    "mitigations=off"
    "plymouth.use-simpledrm"
    "preempt=full"
    "split_lock_detect=off"
    "cpufreq.default_governor=schedutil"
    "amd_pstate=active"
    "transparent_hugepage=always"
    "iommu=pt"
    "amd_iommu=pt"
    "amdgpu.exp_hw_support=1"
    "i915.enable_guc=3"
    "pci=assign-busses,hpbussize=0x33,realloc=on"
    "kvm.enable_virt_at_load=0"
    "amdgpu.dc=1"
    "vfio-pci.disable_vga=1"
  ];

  boot.zswap = {
    enable = true;
    compressor = "zstd";
    shrinkerEnabled = true;
  };

  catppuccin.tty.enable = !isLaptop;

  hardware = {
    amdgpu.overdrive = {
      enable = true;
      ppfeaturemask="0xffffffff";
    };
    
    new-lg4ff.enable = true;
    xpadneo.enable = true;
  };

  boot.kernelPackages = (
    pkgs.linuxKernel.packagesFor(
      pkgs.cachyosKernels.linux-cachyos-rc.override {
        bbr3 = true;
        cpusched = "bore";
        lto = if isLaptop then "thin" else "full";
        processorOpt = if isLaptop then "zen4" else "x86_64-v3";
        tickrate = if isLaptop then "idle" else "full";
      }
    )
  );

  boot.kernelPatches = [ ];

  boot.extraModulePackages = [];

  boot.kernelModules = [];

  boot.blacklistedKernelModules = [];

  services.scx = { # https://wiki.cachyos.org/configuration/sched-ext/#general-recommendations
    enable = false;
    scheduler = "scx_lavd";
    extraArgs = [ "--${if isLaptop then "autopower" else "performance"}" ];
  };

  boot.kernel.sysctl = {
    #"vm.swappiness" = 30; # Already set by cachyos settings
    "vm.max_map_count" = 16777216;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake"; # / "cake_mq"
  };
}
