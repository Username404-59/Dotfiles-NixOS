{ config, pkgs, lib, nixtamal, importFlake, ... }:

let
  functions = rec {
    flakePackages = src: (importFlake src).packages.${pkgs.stdenv.hostPlatform.system};
    flakePackage = src: (flakePackages src).default;

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
    # Takes a package, the mode, and and env like { SOMEENVVAR = "some value" }
    wrapWithNoPreload_env = pkg: classic: env: let
      bwrap_launcher = prog: pkgs.writeShellScript "bwrap-launcher-${pkg.pname}" ''
        # To avoid re-wrapping in case I'm already inside the sandbox
        if [[ -n "''${_NIX_NOPRELOAD_ACTIVE:-}" ]]; then
          exec "${prog}.orig" "$@"
        fi
        export _NIX_NOPRELOAD_ACTIVE=1

        exec ${lib.getExe pkgs.bubblewrap} \
          --dev-bind / / --tmpfs /etc \
          $(find /etc -mindepth 1 -maxdepth 1 ! -name 'ld-nix.so.preload' -printf ' --ro-bind %p %p') \
          ${lib.concatStringsSep " " (
            map
            (name: "--setenv ${name} \"${lib.getAttr name env}\"")
            (lib.attrNames env)
          )} \
          -- ${prog}.orig "$@"
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

        postFixup = (old.postFixup or "") + wrapper_stuff;
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
        override = args: wrapWithNoPreload_env (pkg.override args) false env;
        overrideAttrs = f: wrapWithNoPreload_env (pkg.overrideAttrs f) false env;
        overrideDerivation = f: wrapWithNoPreload_env (pkgs.lib.overrideDerivation pkg f) false env;
      };
    };
    wrapWithNoPreload = pkg: classic: wrapWithNoPreload_env pkg classic {};
  };
in
rec {
  _module.args.functions = functions;

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
    nload
    sbctl # For secure boot
    jq # I use it somewhere in my nixtamal manifest
    steamcmd
    efibootmgr
    kitty.terminfo # To fix ssh output
  ];

  services = {
    nix-serve = {
      enable = true;
      package = pkgs.nix-serve-ng;
      openFirewall = true;
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    nix-ld.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    java = {
      enable = true;
      binfmt = true;
      package = pkgs.graalvmPackages.graalvm-ce;
    };
  };

  environment.sessionVariables = rec {
    NIXTAMAL_DIRECTORY = "tamal";
  };

  environment.shellAliases = {
    nixtamal = "bash -c 'cd ${toString (builtins.dirOf ../nixos/.)} && nixtamal \"$@\"' --";
  };

  # Optimisations
  specialisation.mimalloc.configuration.environment.memoryAllocator.provider = lib.mkForce "mimalloc";
}
