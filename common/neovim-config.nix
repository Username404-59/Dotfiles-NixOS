{ nixtamal, ... }:

{
  imports = [ (import nixtamal.nixvim).outputs.nixosModules.nixvim ];

  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;
    plugins = {
      transparent.enable = true;
    };

    globals = {
      transparent_enabled = true;
    };
  };
}