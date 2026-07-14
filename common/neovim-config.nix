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
      lsp.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings.sources = [
          { name = "nvim_lsp"; group_index = 1; }
          { name = "path";     group_index = 1; }
          { name = "buffer";   group_index = 2; max_item_count = 5; }
        ];
      };
    };

    globals = {
      transparent_enabled = true;
    };
  };
}