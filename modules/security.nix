{ lib, config, ... }:

{
  security.polkit.enable = true;

  # Extra security (especially for SSH)
  services.fail2ban.enable = true;

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
    # Disable setuid for most wrappers, for extra security MUEHEHE 😈
    (lib.mkMerge (map (name: {
      ${name}.setuid = lib.mkForce false;
    }) [
      "fusermount"
      "fusermount3"
      "mount"
      "umount"
      "pkexec"
      "sudo"
      "su"
      "sg"
      "newgrp"
      "newgidmap"
      "newuidmap"
      "passwd" # Also better since I use fscrypt and therefore don't want to accidentally change my password
      "chsh" # This gets handled by home-manager anyway so it's fine
    ]))
  ];
}