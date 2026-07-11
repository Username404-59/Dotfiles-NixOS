{ lib, pkgs, isLaptop, ... }:

let
  uwsm = "${lib.getExe pkgs.app2unit} -- {app_name}";
in {
  home.file.".config/ironbar/config.json".text = builtins.toJSON ({
    monitors.${if isLaptop then "eDP-1" else "DP-3"} = {
      position = "bottom";
      height = 32;
      start = [
        {
          type = "menu";
          label_icon = "distributor-logo-nixos";
          label = "";
          label_icon_size = 44;
          width = 512;
          launch_command = uwsm;
        }
        {
          type = "launcher";
          favorites = [ "firefox" "Dolphin" "kitty" "prismlauncher" "Sober" ];
          show_names = false;
          show_icons = true;
          reversed = false;
          launch_command = uwsm;
        }
        {
          type = "focused";
          show_icon = false;
          show_title = true;
          icon_size = 24;
          truncate.mode = "end";
          truncate.max_length = 25;
        }
      ];
      center = [
        { type = "music"; }
        {
          type = "clock"; justify = "left";
          format = "  %H:%M:%S\n%d/%m/%Y";
          format_popup = "Calendrier";
        }
        {
          type = "sys_info";
          interval.cpu = 1;
          format = [ "   {cpu_percent@mean}% {cpu_frequency@max#M} MHz   " ];
        }
        { type = "volume"; }
      ];
      end = lib.optional isLaptop { type = "upower"; format = "{percentage}%"; } ++ [
        {
          type = "custom";
          name = "power-menu";
          class = "power-menu";

          bar = [ { type = "button"; name="power-btn"; label = "󰐥"; on_click = "popup:toggle"; } ];
            popup = [{
              type = "box";
              orientation = "vertical";
              widgets = [
                {
                  type = "box";
                  orientation = "vertical";
                  name = "buttons";
                  widgets = [
                    { type = "button"; class="power-btn"; label = "󰐥"; on_click = "!shutdown now"; }
                    { type = "button"; class="power-btn"; label = "󰜉"; on_click = "!reboot"; }
                    { type = "button"; class="power-btn"; label = "⏸"; on_click = "!suspend"; }
                    { type = "button"; class="power-btn"; label = "🔒"; on_click = "!hyprlock &"; }
                  ];
                }
              ];
            }];
          }
          #{ type = "network_manager"; icon_size = 32; }
          { type = "tray"; icon_size = 32; }
        ];
      };
    icon_theme = "Papirus-Dark";
  });

  home.file.".config/ironbar/style.css".source = ./ironbar_css/style.css;
}