{ lib, pkgs, functions, isLaptop, ... }:

{
  hardware.graphics = {
    extraPackages = with pkgs; [
      (functions.mkUnstable low-latency-layer) # Better alternative (+ vendor-agnostic) to mesa's amd anti-lag 2
    ];
  };

  # https://docs.mesa3d.org/envvars.html#:~:text=RADV%5FPERFTEST
  environment.sessionVariables.RADV_PERFTEST = lib.mkIf (!isLaptop) "nogttspill";
}