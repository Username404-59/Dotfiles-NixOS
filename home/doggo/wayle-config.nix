{ isLaptop, lib, pkgs, ... }:

{
  services.wayle = {
    enable = true;

    # To translate the TOML config to Nix (according to wiki):
    # nix-instantiate --eval --expr 'builtins.fromTOML (builtins.readFile ./config.toml)' | nixfmt
    settings = {
      modules = {
        bluetooth = {
          label-show = false;
        };
        clock = {
          format = "%a %d %b %H:%M";
        };
        network = {
          label-show = false;
        };
        power = {
          icon-name = "ld-moon-symbolic";
          left-click = "${lib.getExe pkgs.kdePackages.kdialog} --warningyesno \"Vraiment mettre en veille?\" && systemctl sleep";
        };
        weather = {
          location = "Lille";
        };
      };
      general = {
        font-mono = "FiraCode Nerd Font Mono";
        tearing-mode = true;
      };
      wallpaper.engine-enabled = false;

      bar = {
        background-opacity = 66;
        border-location = "all";
        button-bg-opacity = 38;
        dropdown-opacity = 95;
        inset-edge = 0.5;
        inset-ends = 0.5;
        layout = [
          {
            center = [
              "media"
              "clock"
              "volume"
              "microphone"
              "cava"
            ];
            left = [
              "dashboard"
              "hyprland-workspaces"
              "separator"
              "cpu"
            ];
            monitor = if isLaptop then "eDP-1" else "DP-3";
            right = [
              "power"
              "brightness"
              "idle-inhibit"
            ] ++ lib.optional isLaptop "battery" ++ [
              "bluetooth"
              "network"
              "systray"
            ];
            show = true;
          }
        ];
        location = "bottom";
        rounding = "md";
      };

      styling = {
        palette = {
          bg = "#11111b";
          blue = "#74c7ec";
          elevated = "#1e1e2e";
          fg = "#cdd6f4";
          fg-muted = "#bac2de";
          green = "#a6e3a1";
          primary = "#b4befe";
          red = "#f38ba8";
          surface = "#181825";
          yellow = "#f9e2af";
        };
        rounding = "md";
      };
    };
  };
}