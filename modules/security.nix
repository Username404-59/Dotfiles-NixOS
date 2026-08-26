{ lib, config, ... }:

{
  security.polkit.enable = true;

  # Extra security (especially for SSH)
  services.fail2ban.enable = true;

  # Secrets service
  services.oo7.enable = true;

  security.pam.services = let
    pam_options = {
      nodelay = true; # There's no need for extra delay because of YESCRYPT_COST_FACTOR
    };
  in {
    sudo = pam_options;
    su = pam_options;
    login = pam_options // {
      oo7.enable = true;
      gnupg.enable = true;
    };
    hyprlock = pam_options; # Needed by the home-manager's programs.hyprlock.enable
  };

  programs.gnupg.agent = {
    enable = true;
    settings.allow-preset-passphrase = "";
  };

  security.loginDefs.settings = {
    ENCRYPT_METHOD = "YESCRYPT";
    YESCRYPT_COST_FACTOR = "11";
  };

  # I use run0 as a replacement of sudo
  security.sudo.enable = false;
  security.run0 = {
    enable = true;
    sudo-shim.enable = true;
  };
  home-manager.sharedModules = [({
    home.shellAliases.sudo = "sudo --run0-extra-arg '--background='";
  })];

  security.wrappers = lib.mkMerge [
    # Make sure the sudo wrapper is enabled, to use it with the shim
    {
      sudo.enable = true;
      sudo.source = lib.getExe config.security.run0.sudo-shim.package;
      sudo.owner = "root";
      sudo.group = "wheel";
    }
    {
      passwd.enable = false; # Also better since I use fscrypt and therefore don't want to accidentally change my password
      chsh.enable = false; # This gets handled by home-manager anyway so it's fine
    }
    # Disable setuid for most wrappers, for extra security MUEHEHE 😈
    (lib.mkMerge (map (name: {
      ${name}.setuid = lib.mkForce false;
    }) [
      "mount"
      "umount"
      "pkexec"
      "sudo"
      "su"
      "sg"
      "newgrp"
      "newgidmap"
      "newuidmap"
    ]))
  ];
}