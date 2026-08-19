{ functions, pkgs, nixtamal, lib, config, ... }:

let
  ableton = functions.addFlakeCompat nixtamal.ableton-linux;
in
{
  home.packages = [
    ableton.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Hacky activation script to install ableton
  home.activation.ableton = let
    tmp_dir = "$XDG_RUNTIME_DIR/abletonstuff";
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${config.home.homeDirectory}/.wine-ableton" ]; then
      rm -rf ${tmp_dir}
      mkdir ${tmp_dir}
      ln -sf ${nixtamal.ableton} ${tmp_dir}/ableton_live_lite_12.9999.9999_64.zip
      PATH="/run/current-system/sw/bin:${pkgs.unzip}/bin:${pkgs.cabextract}/bin:$PATH" ABLETON_INSTALLER_DIR="${tmp_dir}" ABLETON_LIVE_AUTOINSTALL=1 ABLETON_INSTALLER_UI=0 ${ableton.apps.${pkgs.stdenv.hostPlatform.system}.setup-prefix.program}
      rm -rf ${tmp_dir}
    fi
  '';
}