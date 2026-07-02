{ config, lib, pkgs, ...}:

let
  isLaptop = false;
in
{
  _module.args.isLaptop = isLaptop;
  home-manager.extraSpecialArgs = { inherit isLaptop; };
 
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # Common modules
  ] ++ (if !isLaptop then [
    # Desktop modules
    nct6687d
    r8125
  ] else [
    # Laptop modules
  ]);

  boot.kernelModules = [
    # Common modules
  ] ++ (if !isLaptop then [
    # Desktop modules
    "nct6687" # d disappears in actual module name
    "r8125" # replaces r8169
  ] else [
    # Laptop modules
  ]);

  # CRU screen overclocking
  hardware.firmware = lib.mkIf (!isLaptop) [
    (pkgs.runCommandLocal "PHL-edid-77hz" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${/disk2/Bunker/CRU/PHL_243V5_OC_77MHZ.bin} $out/lib/firmware/edid/PHL_243V5_OC_77MHZ.bin
    '')
  ];

  boot.kernelParams = lib.mkIf (!isLaptop) [
    "drm.edid_firmware=HDMI-A-4:edid/PHL_243V5_OC_77MHZ.bin"
  ];

  programs.coolercontrol.enable = !isLaptop;

  boot.loader.limine.extraEntries = lib.mkIf (!isLaptop) ''
    /Windows
      protocol: efi
      path: label(windows_efi):/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  powerManagement.cpuFreqGovernor = if !isLaptop then "performance" else "schedutil";

  services.auto-cpufreq = {
    enable = isLaptop;
    settings = {
      charger.turbo = "auto";
      battery.turbo = "never";
    };
  };

  fileSystems."/".options = [ "noatime" ];

  networking.hostName = if !isLaptop then "lizard" else "lizard-portable";
}
