{ lib, ... }:

{
  image.modules.iso-installer = {
    boot.supportedFilesystems = {
      f2fs = true;
      zfs = lib.mkForce false; # Pulled by ISO build for some reason, and it's broken as of writing
    };
    boot.zswap.enable = lib.mkForce false;
  };
}