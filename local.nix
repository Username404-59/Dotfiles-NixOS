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
  ] else [
    # Laptop modules
  ]);

  boot.kernelModules = [
    # Common modules
  ] ++ (if !isLaptop then [
    # Desktop modules
    "nct6687" # d disappears in actual module name
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
      path: uuid(F19E62C8-6ED1-4482-976A-6CCF5F561FDD):/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  powerManagement.cpuFreqGovernor = if !isLaptop then "performance" else "schedutil";

  services.auto-cpufreq = {
    enable = isLaptop;
    settings = {
      charger.turbo = "auto";
      battery.turbo = "never";
    };
  };

  fileSystems."/".options = [ "noatime" "discard" ];
  # Note: for f2fs, create it with "sudo fsck.f2fs -O extra_attr,flexible_inline_xattr,inode_checksum,sb_checksum,compression,lost_found /dev/sdxY"
  # & add "noatime,discard" (done here) and "compress_algorithm=lzo-rle,compress_chksum,atgc,gc_merge,checkpoint=enable,checkpoint_merge,fsync_mode=posix,nat_bits" to mount options

  networking.hostName = if !isLaptop then "lizard" else "lizard-portable";
}
