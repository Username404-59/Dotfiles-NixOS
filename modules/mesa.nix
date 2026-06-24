{ lib, pkgs, functions, isLaptop, ... }:

let
  selected_vkDrivers = [ "amd" /* Needed by steam => */ "microsoft-experimental" ] ++ lib.optional (!isLaptop) "intel";
  selected_glDrivers = [ "radeonsi" "zink" ] ++ lib.optional (!isLaptop) "i915";
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
    extraPackages = with pkgs; [
      (functions.mkUnstable low-latency-layer) # Better alternative (+ vendor-agnostic) to mesa's amd anti-lag 2
    ];
  };
}