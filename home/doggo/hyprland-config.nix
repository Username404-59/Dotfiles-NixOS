{ config, pkgs, lib, isLaptop, functions, ... }:

let
  menu_name = "rofi";
  menu = "${menu_name} -show drun -run-command 'app2unit -- {cmd}'";
  uwsm = "uwsm app --";
  terminal = "kitty";
  fileManager = "dolphin";
  mpv_options =  "volume=0";
  mainMod = "SUPER";

  mocha = {
    peach = "rgb(fab387)";
  };

  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  find_monitor = id: "$(${hyprctl} monitors -j | jq -r \".[] | select(.id==${toString id}) | .name\")";

  mkVideoWallpaper = id:
    let
      name = "doggo-video-wallpaper-${id}";
      format = "mkv";
    in
    "$(${pkgs.writeShellApplication {
      inherit name;

      runtimeInputs = [ pkgs.yt-dlp ];

      text = ''
        file="${config.xdg.dataHome}/wallpapers/${id}.${format}"
        if [[ ! -f "$file" ]]; then
          mkdir -p "$(dirname "$file")"
          yt-dlp \
            -f "bestvideo+bestaudio/best" \
            --no-playlist \
            --audio-quality 0 \
            --merge-output-format ${format} \
            --no-embed-thumbnail \
            -o "$file" \
            "https://www.youtube.com/watch?v=${id}" >&2
        fi

        echo $file
      '';
    }}/bin/${name})";

  backgrounds_commands = [
    "swaybg -i ${./backgrounds/ubuntu_budgie_wallpaper1.jpg} -o ${find_monitor 0}"
    "murale ${mkVideoWallpaper "ketQTGwA4Lo"} -o ${find_monitor 1} --mpv-options \"${mpv_options}\""
  ];

  battery_check = "[ \"$(busctl get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery | awk \"{print $2}\")\" = \"true\" ]";

  border_animation = { leaf = "borderangle"; enabled = true; speed = 20.0; bezier = "linear"; style = "loop"; };
  border_animation_lua = "hl.animation(${lib.generators.toLua { multiline = false; } border_animation})";
  border_no_loop_lua = "hl.animation(${lib.generators.toLua { multiline = false; } (border_animation // {
    # Avoids consuming a lot of my laptop's battery:
    # https://wiki.hypr.land/0.55.0/Configuring/Advanced-and-Cool/Animations/#:~:text=Warning
    enabled = false; style = "";
  })})";

  # Start(/stop) my backgrounds on (un)plug
  watch-ac-plug = pkgs.writeShellApplication {
    name = "watch-ac-plug";
    runtimeInputs = [ pkgs.dbus pkgs.gawk ];
    text = ''
      dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',path='/org/freedesktop/UPower'" |
      while read -r line; do
        if echo "$line" | grep -q "OnBattery"; then
          read -r _ state
          if echo "$state" | grep -q "true"; then
            ${hyprctl} eval '${border_no_loop_lua}'
            ${builtins.concatStringsSep " && " (builtins.map (cmd: "pkill -f '.*${cmd}'") backgrounds_commands)}
          else
            ${hyprctl} eval '${border_animation_lua}'
            ${builtins.concatStringsSep " && " (builtins.map (cmd: "${uwsm} ${cmd}") backgrounds_commands)}
          fi
        fi
      done
    '';
  };
in
{
  systemd.user.services.watch-ac-plug = lib.mkIf isLaptop {
      Unit.Description = "Start/stop my backgrounds on AC plug/unplug";
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${watch-ac-plug}/bin/watch-ac-plug";
        Restart = "always";
      };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = false; # Conflicts with UWSM
    };
    plugins = with pkgs.hyprlandPlugins; [
      (functions.mkSpecialVersion hypr-darkwindow "0.55.4")
    ];

    settings = {
      monitor = [
        ({
          # Desktop settings
          output = "DP-3";
          mode = "highres@highrr";
          position = "0x0"; scale = 1; vrr = 2;
        } // lib.optionalAttrs isLaptop {
          # Laptop settings
          output = "eDP-1";
          scale = 1.5;
          cm = "hdredid"; bitdepth = 10;
          min_luminance = 0.0; max_luminance = 2000;
          sdr_min_luminance = 0.005; sdr_max_luminance = 350; # 106?
          sdrsaturation = 1.0; # 1.175? 0.975?
          #sdrbrightness = 1.1; # 1.2625? 0.975?
        })
        { output = ""; mode = "highres@highrr"; position = if isLaptop then "auto-right" else "auto-left"; scale = 1; }
      ];

      # AUTOSTART #
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              ${if isLaptop then ''
                hl.exec_cmd("${uwsm} swaybg -c 000000 -o '*'")
                  hl.exec_cmd('${battery_check} && ${hyprctl} eval ' .. [['${border_no_loop_lua}']])
              '' else ""}
              ${builtins.concatStringsSep "\n  " (builtins.map (cmd:
                "hl.exec_cmd('${if isLaptop then "${battery_check} && " else ""}"
                + "${uwsm} ${cmd}')") backgrounds_commands)
              }
              hl.exec_cmd("${uwsm} ironbar")
              hl.exec_cmd("${uwsm} wl-paste --type text --watch cliphist store")
              hl.exec_cmd("${uwsm} wl-paste --type image --watch cliphist store")
              hl.exec_cmd("${uwsm} hyprsunset")
              hl.exec_cmd("bash -c 'sleep 1.5s && { [ \"$(date +%H)\" -ge 22 ] || [ \"$(date +%H)\" -lt 6 ]; } && hyprctl hyprsunset temperature 3333'")
              hl.exec_cmd("systemctl --user start hyprpolkitagent")
              -- hl.exec_cmd("${uwsm} orbolay")
            end
          '')
        ];
      };

      # LOOK & FEEL #
      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 3;

          col.active_border = {
            colors = [
              "rgba(33ccffee)"
              mocha.peach
              "rgba(00ff99ee)"
            ];
            angle = 45;
          };
          col.inactive_border = { colors = [ "rgba(171727b0)" ]; };
          resize_on_border = false;
          allow_tearing = true;
          layout = "dwindle";
        };

        render = {
          direct_scanout = 1;
          new_render_scheduling = true;
        };

        cursor = {
          no_hardware_cursors = 2;
          no_break_fs_vrr = 2;
          min_refresh_rate = 48;
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;

          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 5;
            passes = 4;
            new_optimizations = true;
            vibrancy = 0.75;
            vibrancy_darkness = 1.0;
          };
        };

        animations = {
          enabled = true;
          workspace_wraparound = true;
        };

        dwindle = {
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        # INPUT #
        input = {
          kb_layout = "fr,us";
          follow_mouse = 1;
          focus_on_close = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = false;
          };
        };

        misc = {
          force_default_wallpaper = 1;
          disable_hyprland_logo = false;
        };

        plugin = {
          darkwindow.load_shaders = "chromakey";
        };
      };

      curve = [
        { _args = ["easeOutQuint"     { type = "bezier"; points = [ [0.23 1]    [0.32 1]  ]; } ]; }
        { _args = ["easeInOutCubic"   { type = "bezier"; points = [ [0.65 0.05] [0.36 1]  ]; } ]; }
        { _args = ["linear"           { type = "bezier"; points = [ [0 0]       [1    1]  ]; } ]; }
        { _args = ["almostLinear"     { type = "bezier"; points = [ [0.5 0.5]   [0.75 1]  ]; } ]; }
        { _args = ["quick"            { type = "bezier"; points = [ [0.15 0]    [0.1  1]  ]; } ]; }
        { _args = ["easy"             { type = "spring"; mass = 1; stiffness = 71.2633; dampening = 15.8273644; } ]; }
      ];

      animation = [
        { leaf = "global";        enabled = true;  speed = 10;   bezier = "default";                            }
        { leaf = "border";        enabled = true;  speed = 5.39; bezier = "easeOutQuint";                       }
        { leaf = "windows";       enabled = true;  speed = 4.79; spring = "easy";                               }
        { leaf = "windowsIn";     enabled = true;  speed = 4.1;  spring = "easy";          style = "popin 87%"; }
        { leaf = "windowsOut";    enabled = true;  speed = 1.49; bezier = "linear";        style = "popin 87%"; }
        { leaf = "fadeIn";        enabled = true;  speed = 1.73; bezier = "almostLinear";                       }
        { leaf = "fadeOut";       enabled = true;  speed = 1.46; bezier = "almostLinear";                       }
        { leaf = "fade";          enabled = true;  speed = 3.03; bezier = "quick";                              }
        { leaf = "layers";        enabled = true;  speed = 3.81; bezier = "easeOutQuint";                       }
        { leaf = "layersIn";      enabled = true;  speed = 4;    bezier = "easeOutQuint";  style = "fade";      }
        { leaf = "layersOut";     enabled = true;  speed = 1.5;  bezier = "linear";        style = "fade";      }
        { leaf = "fadeLayersIn";  enabled = true;  speed = 1.79; bezier = "almostLinear";                       }
        { leaf = "fadeLayersOut"; enabled = true;  speed = 1.39; bezier = "almostLinear";                       }
        { leaf = "workspaces";    enabled = true;  speed = 1.94; bezier = "almostLinear";  style = "fade";      }
        { leaf = "workspacesIn";  enabled = true;  speed = 1.21; bezier = "almostLinear";  style = "fade";      }
        { leaf = "workspacesOut"; enabled = true;  speed = 1.94; bezier = "almostLinear";  style = "fade";      }
        # Animated border
        border_animation
      ];

      gesture = {
        fingers = 2;
        direction = "right";
        action = "workspace";
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # KEYBINDINGS #
      bind = let
        mkBind = key: lua: opts:
          { _args = [ key (lib.generators.mkLuaInline lua) ] ++ lib.optional (opts != {}) opts; };
        exec = cmd: "hl.dsp.exec_cmd(\"${cmd}\")";
      in [
        (mkBind "${mainMod} + A" (exec terminal) {})
        (mkBind "${mainMod} + C" "hl.dsp.window.close()" { locked = true; })
        (mkBind "${mainMod} + E" (exec fileManager) {})
        (mkBind "${mainMod} + V" "hl.dsp.window.float({ action = \"toggle\" })" {})
        (mkBind "${mainMod} + P" "hl.dsp.window.pseudo()" {})
        (mkBind "${mainMod} + J" "hl.dsp.layout(\"togglesplit\")" {})
        (mkBind "${mainMod} + F" "hl.dsp.window.fullscreen({ mode = 0, action = \"toggle\" })" {})
        (mkBind "${mainMod} + R" "hl.dsp.window.fullscreen({ mode = 1, action = \"toggle\" })" {})

        (mkBind "${mainMod} + left"  "hl.dsp.focus({ direction = \"left\" })"  {})
        (mkBind "${mainMod} + right" "hl.dsp.focus({ direction = \"right\" })" {})
        (mkBind "${mainMod} + up"    "hl.dsp.focus({ direction = \"up\" })"    {})
        (mkBind "${mainMod} + down"  "hl.dsp.focus({ direction = \"down\" })"  {})

        (mkBind "${mainMod} + S"         "hl.dsp.workspace.toggle_special(\"magic\")" {})
        (mkBind "${mainMod} + SHIFT + S" "hl.dsp.window.move({ workspace = \"special:magic\" })" {})

        (mkBind "${mainMod} + mouse_down" "hl.dsp.focus({ workspace = \"m+1\" })" {})
        (mkBind "${mainMod} + mouse_up"   "hl.dsp.focus({ workspace = \"m-1\" })" {})

        (mkBind "${mainMod} + SUPER_L" (exec "pkill ${menu_name} || ${menu}") {})
        (mkBind "${mainMod} + W"       (exec "cliphist list | rofi -dmenu | cliphist decode | wl-copy") {})
        (mkBind "CTRL + ALT + A"       (exec "pkill ${menu_name} || ${uwsm} ani-cli --${menu_name}") { long_press = true; })

        (mkBind "${mainMod} + mouse:272" "hl.dsp.window.drag()"   { mouse = true; })
        (mkBind "${mainMod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

        (mkBind "XF86AudioRaiseVolume"  (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")  { locked = true; repeating = true; })
        (mkBind "XF86AudioLowerVolume"  (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")       { locked = true; repeating = true; })
        (mkBind "XF86AudioMute"         (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")      { locked = true; repeating = true; })
        (mkBind "XF86AudioMicMute"      (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")    { locked = true; repeating = true; })
        (mkBind "XF86MonBrightnessUp"   (exec "hyprctl hyprsunset gamma +5")                     { locked = true; repeating = true; })
        (mkBind "XF86MonBrightnessDown" (exec "hyprctl hyprsunset gamma -5")                     { locked = true; repeating = true; })

        (mkBind "XF86AudioNext"  (exec "playerctl next")       { locked = true; })
        (mkBind "XF86AudioPause" (exec "playerctl play-pause") { locked = true; })
        (mkBind "XF86AudioPlay"  (exec "playerctl play-pause") { locked = true; })
        (mkBind "XF86AudioPrev"  (exec "playerctl previous")   { locked = true; })

        (mkBind "${mainMod} + PRINT" (exec "hyprshot -m window") {})
        (mkBind "PRINT"              (exec "hyprshot -m output") { locked = true; })
        (mkBind "SHIFT + PRINT"      (exec "hyprshot -m region") {})
      ] ++ lib.concatMap (i:
        let
          ws   = toString i;
          code = toString (i + 9);
        in [
          (mkBind "${mainMod} + code:${code}"         "hl.dsp.focus({ workspace = ${ws} })"       {})
          (mkBind "${mainMod} + SHIFT + code:${code}" "hl.dsp.window.move({ workspace = ${ws} })" {})
        ]
      ) (lib.range 1 9);

      # WINDOW RULES #
      window_rule = [
        { name = "suppress-maximize-events"; match = { class = ".*"; }; }
        {
          name = "fix-xwayland-drags";
          match = {
            class      = "^$";
            title      = "^$";
            xwayland   = true;
            float      = true;
            fullscreen = false;
            pin        = false;
          };
        }
        /*
        {
          name = "fix-orbolay";
          match = {
            title = "^(orbolay)$";
          };
          no_initial_focus = true;
          suppress_event = "activatefocus";
          float = true;
          pin = true;
          center = true;
          no_blur = true;
          no_dim = true;
          no_follow_mouse = true;
          no_shadow = true;
          border_size = 0;
          no_focus = true;
          move = [ "monitor_w" "monitor_h" ];
          size = [ "monitor_w - 5" "monitor_h - 5" ];
        }
        */
        # Chromakey with Catppuccin Mocha Base (the hex values each divided by 255 -> 0.1176, 0.1176, 0.1804)
        {
          name = "transparency";
          match.class = "^(${builtins.concatStringsSep "|" [ # To check app classes: "hyprctl clients"
            "spotify" "jetbrains-.*"
            "io.github.ilya_zlobintsev.LACT"
            "org.prismlauncher.PrismLauncher"
            "com.obsproject.Studio"
            "${config.programs.chromium.package.pname}-browser"
            "org.kde.*|qt.*|.*qt.*|.*Qt.*"
          ]})$";

          "darkwindow:shade" = lib.generators.mkLuaInline ''
            hl.plugin.darkwindow.build_window_rule({
              shader = "chromakey",
              args = {
                bkg = { 0.1176, 0.1176, 0.1804 },
                targetOpacity = 0.78,
                similarity = 0.20,
                amount = 0.7
              }
            })
          '';
        }
        # Chromakey for Steam; https://www.color-hex.com/color-palette/1050902
        {
          name = "steam-transparency";
          match = { class = "steam"; };
          "darkwindow:shade" = lib.generators.mkLuaInline ''
            hl.plugin.darkwindow.build_window_rule({
              shader = "chromakey",
              args = {
                bkg = { 0.1607, 0.1803, 0.2156 },
                targetOpacity = 0.78,
                similarity = 0.1185,
                amount = 0.7
              }
            })
          '';
        }
      ];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      anchor = "bottom-right";
      default-timeout = 5000;
      ignore-timeout = 1;
      history = 0;
      output = (builtins.elemAt config.wayland.windowManager.hyprland.settings.monitor 0).output;
    };
  };

  programs.hyprlock.enable = true;
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };
      listener = [
        {
          on-timeout = "hyprctl hyprsunset gamma_max 10";
          on-resume = "hyprctl hyprsunset gamma_max 100";
          timeout = 150;
        }
        {
          on-timeout = "hyprlock";
          timeout = 600;
        }
        {
          # Turns screen off/on
          on-resume = "hyprctl dispatch dpms on";
          on-timeout = "hyprctl dispatch dpms off";
          timeout = 660;
        }
      ] ++ lib.optional isLaptop {
        on-timeout = "suspend";
        timeout = 900;
      };
    };
  };

  # TODO Use hyprproxlock to make the screen unlock when I approach my laptop with earbuds / my bangle.js BECAUSE WHY THE FUCK NOT
}
