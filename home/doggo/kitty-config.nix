{ ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      mode = "enabled";
      enableFishIntegration = true;
    };
    settings = {
      shell = "fish";
      font_family = "FiraCode Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      cursor_shape = "beam";
      disable_ligatures = "cursor";

      font_size = 12;

      scrollback_lines = 4096;
      enable_audio_bell = "no";
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";

      sync_to_monitor = "no";
      background_opacity = 0.75;
      initial_window_width = 576;
      initial_window_height = 512;

      remember_window_size = "no";
      window_padding_width = 6;
      placement_strategy = "center";
      hide_window_decorations = "yes";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disables greeting
    '';
  };

  # Shell prompt stuff
  programs.starship = {
    enable = true;
    presets = [
      "nerd-font-symbols"
      "jetpack"
    ];
  };
}
