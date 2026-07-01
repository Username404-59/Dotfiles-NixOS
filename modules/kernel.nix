{ config, pkgs, lib, isLaptop, nixtamal, ... }:

{
  boot.kernelParams = [
    "sysrq_always_enabled=1"
    "mitigations=off"
    "plymouth.use-simpledrm"
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.zpool=zsmalloc"
    "vm.swappiness=30"
    "preempt=full"
    "split_lock_detect=off"
    "cpufreq.default_governor=schedutil"
    "amd_pstate=active"
    "transparent_hugepage=always"
    "iommu=pt"
    "amd_iommu=pt"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.exp_hw_support=1"
    "i915.enable_guc=3"
    "pci=assign-busses,hpbussize=0x33,realloc=on"
    "kvm.enable_virt_at_load=0"
    "amdgpu.dc=1"
    "amdgpu.gpu_recovery=1"
    "vfio-pci.disable_vga=1"
  ];

  catppuccin.tty.enable = !isLaptop;

  hardware = {
    amdgpu.overdrive = {
      enable = true;
      ppfeaturemask="0xffffffff";
    };
    
    new-lg4ff.enable = true;
  };

  boot.kernelPackages = (
    pkgs.linuxKernel.packagesFor(
      pkgs.cachyosKernels.linux-cachyos-latest.override {
        bbr3 = true;
        cpusched = "eevdf"; # / "bore"
        lto = if isLaptop then "thin" else "full";
        processorOpt = if isLaptop then "zen4" else "x86_64-v3";
        tickrate = if isLaptop then "idle" else "full";
      }
    )
  );

  boot.kernelPatches = [
    {
      name = "infinity-scheduler";
      patch = "${nixtamal.infinity-scheduler}/patches/stable/linux-${
        lib.versions.majorMinor config.boot.kernelPackages.kernel.version
      }-infinity/0001-infinity-scheduler.patch";
    }
  ];

  services.scx = { # https://wiki.cachyos.org/configuration/sched-ext/#general-recommendations
    enable = true; # Disable this to use the infinity scheduler
    scheduler = "scx_flow";
    extraArgs = [ /* TODO for next scx version after 1.1.1: "--no-webui" */ ];
  };

  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake_mq";
  };
}
