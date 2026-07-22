{ config, pkgs, lib, nixtamal, isLaptop, ... }:

let
  functions = rec {
    mkSpecial = pkg: version: src_name: suffix:
      let
        src = nixtamal.${src_name + suffix};
      in pkg.overrideAttrs (old: {
        inherit version src;
      } // lib.optionalAttrs (old ? cargoDeps) { # Removes the need to set the cargo vendor hash (that nixtamal doesn't handle, obviously)
        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = "${src}/Cargo.lock";
        };
      });
    mkSpecialAuto = pkg: version: suffix: mkSpecial pkg version pkg.pname suffix;
    mkSpecialVersion = pkg: version: mkSpecialAuto pkg version "";
    mkUnstable = pkg: mkSpecialAuto pkg "unstable" "-git";

    mkPatched = pkg: newPatches:
      pkg.overrideAttrs (old: {
        patches = newPatches;
      });
    mkPatchedAuto = pkg: mkPatched pkg [ nixtamal.${pkg.pname + "-patch"} ];

    mkWithCFlags = pkg: flags: (pkg.override {
      stdenv = pkgs.fastStdenv; # Faster GCC
    }).overrideAttrs (old: {
      NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " ${flags}"; # https://gcc.gnu.org/onlinedocs/gcc-16.1.0/gcc/Optimize-Options.html
    });

    # Fixes stuff that doesn't work with preloaded mimalloc.
    # With 2 modes because the first thing I wrote doesn't work for chromium...
    wrapWithNoPreload = pkg: classic: let
      bwrap_launcher = prog: pkgs.writeShellScript "bwrap-launcher-${pkg.pname}" ''
        # To avoid re-wrapping in case I'm already inside the sandbox
        if [[ -n "''${_NIX_NOPRELOAD_ACTIVE:-}" ]]; then
          exec "${prog}.orig" "$@"
        fi
        export _NIX_NOPRELOAD_ACTIVE=1

        etc_ro_binds=""
        for path in /etc/* /etc/.*; do
          [[ -e "$path" ]] || continue
          [[ "$path" == "/etc/ld-nix.so.preload" ]] && continue
          etc_ro_binds="$etc_ro_binds --ro-bind $path $path"
        done
        exec ${lib.getExe pkgs.bubblewrap} --dev-bind / / --tmpfs /etc $etc_ro_binds -- ${prog}.orig "$@"
      '';
      exe = baseNameOf (lib.getExe pkg);
      wrapper_stuff = ''
        mv "$out/bin/${exe}" "$out/bin/${exe}.orig"
        makeWrapper ${bwrap_launcher exe} "$out/bin/${exe}"
      '';
      nativeBuildInputs = [
        pkgs.makeWrapper
        pkgs.util-linux
      ];
      buildInputs = [
        pkgs.bubblewrap
      ];
    in if classic then
      pkg.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ nativeBuildInputs;
        buildInputs = (old.buildInputs or []) ++ buildInputs;

        postFixup = let
          exe = baseNameOf (lib.getExe pkg);
        in (old.postFixup or "") + wrapper_stuff;
      })
    else pkgs.symlinkJoin {
      name = "${pkg.name}-no-preload";
      paths = [ pkg ];

      inherit nativeBuildInputs;
      inherit buildInputs;

      postBuild = wrapper_stuff;

      pname = pkg.pname or pkg.name;
      version = pkg.version or "";
      meta = pkg.meta or {};
      passthru = (pkg.passthru or {}) // {
        inherit (pkg) override;
      };
    };
  };
in
rec {
  _module.args.functions = functions;
  home-manager.extraSpecialArgs = { inherit functions; };

  environment.systemPackages = with pkgs; [
    git git-lfs
    curl
    wget
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
    steamcmd
  ];

  services = {
    flatpak = {
      enable = true;
      package = pkgs.flatpak.overrideAttrs {
        patches = [ ../tamal/patches/5224_all_syscalls.patch ];
      };
    };

    lact.enable = true;

    sunshine = { # Default port: 47990
      enable = !isLaptop;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };

  programs = {
    steam = {
      enable = true;
      dedicatedServer.openFirewall = true; # 27015 port
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

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    partition-manager.enable = true;
  };

  environment.sessionVariables = rec {
    NIXTAMAL_DIRECTORY = "tamal";
  };

  environment.shellAliases = {
    nixtamal = "bash -c 'cd /etc/nixos && nixtamal \"$@\"' --";
  };

  home-manager.sharedModules = [(
    { ... }: {
      home.shellAliases = {
        nixtamal = environment.shellAliases.nixtamal;
      };
      programs.nix-index.package = (import nixtamal.nix-index-database { inherit pkgs; }).nix-index-with-small-db;
    }
  )];

  # Optimisations
  environment.memoryAllocator.provider = "mimalloc";
}
