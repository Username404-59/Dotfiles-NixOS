{ lib, pkgs, functions, isLaptop, ... }:

let
  selected_vkDrivers = [ "amd" ] ++ lib.optional (!isLaptop) "intel";
  selected_glDrivers = [ "radeonsi" "zink" /* Needed by steam => */ "d3d12" ] ++ lib.optional (!isLaptop) "i915";
in
{
  hardware.graphics = {
    # Mesa-git because why not
    package = (functions.mkUnstable pkgs.mesa).override {
      vulkanDrivers = selected_vkDrivers;
      galliumDrivers = selected_glDrivers;
    };
    package32 = (functions.mkUnstable pkgs.pkgsi686Linux.mesa).override {
      vulkanDrivers = selected_vkDrivers;
      galliumDrivers = selected_glDrivers;
    };
  };
}