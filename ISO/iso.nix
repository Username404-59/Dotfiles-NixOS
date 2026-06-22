{ lib, ... }:

{
  boot.supportedFilesystems = {
    f2fs = true;
    zfs = lib.mkForce false; # Pulled by ISO build for some reason, and it's broken as of writing
  };
}