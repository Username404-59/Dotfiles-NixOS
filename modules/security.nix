{ lib, ... }:

{
  security.polkit.enable = true;

  # Extra security (especially for SSH)
  services.fail2ban.enable = true;

  # I use run0 (via an alias) instead
  security.sudo.enable = false;
  home-manager.sharedModules = [({
    home.shellAliases.sudo = "run0 --background=";
  })];

  # Disable setuid for most wrappers, for extra security MUEHEHE 😈
  security.wrappers = lib.mkMerge (
    map (name: {
      ${name}.setuid = lib.mkForce false;
    })
    [
      "fusermount"
      "fusermount3"
      "mount"
      "umount"
      "pkexec"
      "su"
      "sg"
      "newgrp"
      "newgidmap"
      "newuidmap"
      "passwd" # Also better since I use fscrypt and therefore don't want to accidentally change my password
      "chsh" # This gets handled by home-manager anyway so it's fine
    ]
  );
}