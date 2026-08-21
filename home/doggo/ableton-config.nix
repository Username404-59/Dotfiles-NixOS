{ functions, pkgs, nixtamal, lib, config, ... }:

let
  ableton = functions.addFlakeCompat nixtamal.ableton-linux;
  major_version = "12";
  wineprefix_ableton = "${config.home.homeDirectory}/.wine-ableton";
in
{
  home.packages = [
    ableton.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Note: for online auth, if firefox doesn't work, check for a "ableton://authorize?license_id=" in console logs and run "ableton-live ableton://authorize?license_id=stuffhere"

  # Hacky script to install ableton
  systemd.user.services.ableton-install = let
    tmp_dir = "$XDG_RUNTIME_DIR/abletonstuff";
  in {
    Install.WantedBy = [ "default.target" ];

    Service = {
      Type = "exec";

      ExecStart = pkgs.writeShellScript "install-ableton" ''
        set -euo pipefail
        if [ -e "${wineprefix_ableton}" ]; then
          exit 0
        fi
        rm -rf "${tmp_dir}"
        mkdir "${tmp_dir}"
        ln -s \
          "${nixtamal.ableton}" \
          "${tmp_dir}/ableton_live_lite_${major_version}.9999.9999_64.zip"

        PATH="${pkgs.unzip}/bin:${pkgs.cabextract}/bin:$PATH" \
          ABLETON_INSTALLER_DIR="${tmp_dir}" \
          ABLETON_LIVE_AUTOINSTALL=1 \
          ABLETON_INSTALLER_UI=0 \
          ${ableton.apps.${pkgs.stdenv.hostPlatform.system}.setup-prefix.program}

        rm -rf "${tmp_dir}"
      '';

      TimeoutStartSec = "30min";
    };
  };

  # Catppuccin theme install
  systemd.user.services.wine-ableton-catppuccin-link = {
    Install.WantedBy = [ "default.target" ];

    Service.Type = "oneshot";
    Service.ExecStart = ''
      ${lib.getExe pkgs.bash} -c '[[ -d "${wineprefix_ableton}" ]] && ln -sfn "${nixtamal.catppuccin-ableton}" "${wineprefix_ableton}/drive_c/ProgramData/Ableton/Live ${major_version} Lite/Resources/Themes/Catppuccin.ask"'
    '';
  };
}