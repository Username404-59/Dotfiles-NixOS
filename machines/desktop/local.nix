{ config, lib, pkgs, functions, ...}:

{

  boot.extraModulePackages = with config.boot.kernelPackages; [
    nct6687d
  ];

  boot.kernelModules = [
    "nct6687" # d disappears in actual module name
  ];

  boot.blacklistedKernelModules = [];

  # TODO: Remove this if my laptop & desktop ever end up having the same microarchitecture
  boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;

  # CRU screen overclocking
  hardware.firmware = [
    (pkgs.runCommandLocal "PHL-edid-77hz" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${/disk2/Bunker/CRU/PHL_243V5_OC_77MHZ.bin} $out/lib/firmware/edid/PHL_243V5_OC_77MHZ.bin
    '')
  ];

  boot.kernelParams = [
    "drm.edid_firmware=HDMI-A-4:edid/PHL_243V5_OC_77MHZ.bin"
  ];

  programs.coolercontrol.enable = true;
  # To fix it with my immutable /etc setup
  environment.etc."coolercontrol".source = "/var/lib/coolercontrol";
  systemd.services.coolercontrold.serviceConfig.StateDirectory = "coolercontrol";

  boot.loader.limine.extraEntries = ''
    /Windows
      protocol: efi
      path: fslabel(windows_efi):/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  powerManagement.cpuFreqGovernor = "performance";

  networking.hostName = "lizard";
}
