{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime # for OpenCL
    ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}