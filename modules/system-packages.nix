{ pkgs, lib, nixtamal, ... }:

let
  functions = rec {
    mkSpecial = pkg: version: src_name: suffix:
      pkg.overrideAttrs (old: {
        inherit version;
        src = nixtamal.${src_name + suffix};
      });
    mkSpecialAuto = pkg: version: suffix: mkSpecial pkg version pkg.pname suffix;
    mkSpecialVersion = pkg: version: mkSpecialAuto pkg version "";
    mkUnstable = pkg: mkSpecialAuto pkg "unstable" "-git";

    mkPatched = pkg: newPatches:
      pkg.overrideAttrs (old: {
        patches = newPatches;
      });
    mkPatchedAuto = pkg: mkPatched pkg [ nixtamal.${pkg.pname + "-patch"} ];

    importFlake = flakeRef:
      let
        src = nixtamal.${flakeRef};
      in
        ((import nixtamal.flake-compat { inherit pkgs; }) {
          inherit src;
        }).defaultNix.packages.${pkgs.system}.default;
  };
in
{
  _module.args.functions = functions;
  home-manager.extraSpecialArgs = { inherit functions; };

  environment.systemPackages = with pkgs; [
    git git-lfs
    curl
    wget
    neovim
    fastfetch
    htop
    killall
    file
    e2fsprogs
    cpu-x
    steam-run
    exfatprogs
    pkgs.nixtamal # Important
    android-tools
    kdePackages.kleopatra # Needed to add keys easily
    nload
    graalvmPackages.graalvm-ce # Java
    clang gcc mold
    cmake
    sbctl # For secure boot with Limine
    jq # I use it somewhere in my nixtamal manifest
    (functions.mkSpecial lsfg-vk-ui "unstable" "lsfg-vk" "-git")
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      dw-proton-bin # From nix-citizen overlay
    ];
    # Note: to make another disk visible to games add
    # STEAM_COMPAT_MOUNTS=/disk2 %command%
    # to commandline options
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  services.flatpak.enable = true;
  systemd.user.services.flatpak-repos = {
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.bash}/bin/sh -c '" +
        "${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && " +
        "${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo" +
      "'";
    };
    wantedBy = [ "default.target" ];
  };

  services.lact = {
    enable = true;
    package = functions.mkPatchedAuto pkgs.lact;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  programs.partition-manager.enable = true;

  environment.sessionVariables = rec {
    NIXTAMAL_DIRECTORY = "tamal";
  };

  environment.shellAliases = {
    nixtamal = "bash -c 'cd /etc/nixos && nixtamal \"$@\"' --";
  };
}
