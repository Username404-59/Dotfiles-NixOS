{ pkgs, functions, ... }:

{
  programs.chromium = {
    enable = true;
    package = functions.wrapWithNoPreload pkgs.ungoogled-chromium false;
  };
}