{ config, lib, pkgs, functions, ...}:

{

  boot.extraModulePackages = with config.boot.kernelPackages; [
    (functions.mkPatchedAuto nct6687d)
  ];

  boot.kernelModules = [
    "nct6687" # d disappears in actual module name
  ];

  boot.blacklistedKernelModules = [];

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

  boot.loader.limine.extraEntries = ''
    /Windows
      protocol: efi
      path: fslabel(windows_efi):/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  powerManagement.cpuFreqGovernor = "performance";

  networking.hostName = "lizard";
}
