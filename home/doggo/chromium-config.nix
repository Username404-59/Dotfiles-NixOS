{ pkgs, functions, ... }:

{
  programs.chromium = {
    enable = true;
    package = functions.wrapWithNoPreload pkgs.chromium;
  };
}