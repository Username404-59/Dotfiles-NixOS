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

  find_monitor = id: "$(hyprctl monitors -j | jq -r '.[] | select(.id==${toString id}) | .name')";

  mkVideoWallpaper = id: hash:
    "${(pkgs.stdenv.mkDerivation {
      name = "doggo-video-wallpaper-${id}";

      buildInputs = [ pkgs.yt-dlp ];

      outputHashMode = "recursive";
      outputHashAlgo = "blake3";
      outputHash = hash; # lib.fakeHash doesn't work for blake3 so I'll have to pass empty strings to find the hashes easily

      buildCommand = ''
        cd $out

        yt-dlp \
          -f "bestvideo[ext=mp4]+251/best[ext=mp4]" \
          --no-playlist \
          --audio-quality 0 \
          -o "wallpaper.mp4" \
          "https://www.youtube.com/watch?v=${id}"
      '';
    })}/wallpaper.mp4";

  backgrounds_commands = [
    "swaybg -i '${./backgrounds/ubuntu_budgie_wallpaper1.jpg}' -o ${find_monitor 0}"
    "murale ${mkVideoWallpaper "ketQTGwA4Lo" "blake3-yvuyjhbBTCqhsxmrjXE3cccC/F+8MisTCpnH+2v8h9w="} -o ${find_monitor 1} --mpv-options '${mpv_options}'"
  ];

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
            ${builtins.concatStringsSep " && " (builtins.map (cmd: "pkill -f '.*${cmd}'") backgrounds_commands)}
          else
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
              hl.exec_cmd("${uwsm} swaybg -c 000000 -o '*'")
              ${builtins.concatStringsSep "\n  " (builtins.map (cmd:
                "hl.exec_cmd(\"${if isLaptop then "[ \"$(busctl get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery | awk '{print $2}')\" = \"true\" ] && " else ""}"
                + "${uwsm} ${cmd}\")") backgrounds_commands)
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
        { leaf = "borderangle";   enabled = true;  speed= 20.0;  bezier = "linear";        style = "loop";      }
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
      bind = [
        { _args = [ "${mainMod} + A"  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${terminal}\")") ]; }
        { _args = [ "${mainMod} + C"  (lib.generators.mkLuaInline "hl.dsp.window.close()") { locked = true; } ]; }
        { _args = [ "${mainMod} + E"  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${fileManager}\")") ]; }
        { _args = [ "${mainMod} + V"  (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\"})") ]; }
        { _args = [ "${mainMod} + P"  (lib.generators.mkLuaInline "hl.dsp.window.pseudo()") ]; }
        { _args = [ "${mainMod} + J"  (lib.generators.mkLuaInline "hl.dsp.layout(\"togglesplit\")") ]; }
        { _args = [ "${mainMod} + F"  (lib.generators.mkLuaInline "hl.dsp.window.fullscreen({ mode = 0, action = \"toggle\" })") ]; }
        { _args = [ "${mainMod} + R"  (lib.generators.mkLuaInline "hl.dsp.window.fullscreen({ mode = 1, action = \"toggle\" })") ]; }

        { _args = [ "${mainMod} + left"  (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"left\" })") ]; }
        { _args = [ "${mainMod} + right" (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"right\" })") ]; }
        { _args = [ "${mainMod} + up"    (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"up\" })") ]; }
        { _args = [ "${mainMod} + down"  (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"down\" })") ]; }

        { _args = [ "${mainMod} + S"         (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"magic\")") ]; }
        { _args = [ "${mainMod} + SHIFT + S" (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = \"special:magic\" })") ]; }

        { _args = [ "${mainMod} + mouse_down" (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })") ]; }
        { _args = [ "${mainMod} + mouse_up"   (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })") ]; }

        { _args = [ "${mainMod} + SUPER_L"   (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill ${menu_name} || ${menu}\")") ]; }
        { _args = [ "${mainMod} + W"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"cliphist list | rofi -dmenu | cliphist decode | wl-copy\")") ]; }
        { _args = [ "CTRL + ALT + A"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill ${menu_name} || ${uwsm} ani-cli --${menu_name}\")") { long_press = true; } ]; }

        { _args = [ "${mainMod} + mouse:272" (lib.generators.mkLuaInline "hl.dsp.window.drag()") { mouse = true; } ]; }
        { _args = [ "${mainMod} + mouse:273" (lib.generators.mkLuaInline "hl.dsp.window.resize()") { mouse = true; } ]; }

        { _args = [ "XF86AudioRaiseVolume"  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")") { locked = true; repeating = true; } ]; }
        { _args = [ "XF86AudioLowerVolume"  (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")") { locked = true; repeating = true; } ]; }
        { _args = [ "XF86AudioMute"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")") { locked = true; repeating = true; } ]; }
        { _args = [ "XF86AudioMicMute"      (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")") { locked = true; repeating = true; } ]; }
        { _args = [ "XF86MonBrightnessUp"   (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl hyprsunset gamma +5\")") { locked = true; repeating = true; } ]; }
        { _args = [ "XF86MonBrightnessDown" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprctl hyprsunset gamma -5\")") { locked = true; repeating = true; } ]; }

        { _args = [ "XF86AudioNext"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")") { locked = true; } ]; }
        { _args = [ "XF86AudioPause"        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")") { locked = true; } ]; }
        { _args = [ "XF86AudioPlay"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")") { locked = true; } ]; }
        { _args = [ "XF86AudioPrev"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")") { locked = true; } ]; }

        { _args = [ "${mainMod} + PRINT"    (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprshot -m window\")") ]; }
        { _args = [ "PRINT"                 (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprshot -m output\")") { locked = true; } ]; }
        { _args = [ "SHIFT + PRINT"         (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"hyprshot -m region\")") ]; }

        /*
        { _args = ["${mainMod} + 1" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 2" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 3" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 4" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 5" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 6" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 7" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 8" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 9" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + 0" (lib.generators.mkLuaInline ) ]; }

        { _args = ["${mainMod} + SHIFT + 1" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 2" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 3" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 4" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 5" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 6" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 7" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 8" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 9" (lib.generators.mkLuaInline ) ]; }
        { _args = ["${mainMod} + SHIFT + 0" (lib.generators.mkLuaInline ) ]; }
        */
      ]; /* ++ (
        builtins.concatLists (builtins.genList (i:
          in [
            { _args = ["${mainMod} + ${toString i}"         (lib.generators.mkLuaInline ) "hl.dsp.focus({ workspace = ${toString i} })"]; }
            { _args = ["${mainMod} + SHIFT + ${toString i}" (lib.generators.mkLuaInline ) "hl.dsp.window.move({ workspace = ${toString i} })"]; }
          ]
        )
        9)
      ); */

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
          match = { class = "^(spotify|jetbrains-.*|io.github.ilya_zlobintsev.LACT|org.prismlauncher.PrismLauncher|org.kde.*|qt.*|.*qt.*|.*Qt.*)$"; };
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
}
