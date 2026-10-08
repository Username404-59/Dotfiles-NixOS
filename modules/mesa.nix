{ lib, pkgs, functions, isLaptop, ... }:

{
  hardware.graphics = {
    extraPackages = with pkgs; [
      # TODO Remove when mesa 26.3 is out: https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/42048
      (functions.mkUnstable low-latency-layer) # Better alternative (+ vendor-agnostic) to mesa's amd anti-lag 2
    ];
  };

  # https://docs.mesa3d.org/envvars.html#:~:text=RADV%5FPERFTEST
  environment.sessionVariables.RADV_PERFTEST = lib.mkIf (!isLaptop) "nogttspill";
}