{ nixtamal, ... }:

{
  imports = [ (import nixtamal.nixvim).outputs.nixosModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    colorschemes.catppuccin.enable = true;
    plugins = {
      transparent.enable = true;
      lualine.enable = true;
    };

    globals = {
      transparent_enabled = true;
    };
  };
}