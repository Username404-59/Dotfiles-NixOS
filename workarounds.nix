{ ... }:

{
  documentation.nixos.enable = false; # In case something's documentation is making nixos-rebuild fail

  # Fixes for services broken by system.etc.overlay.mutable (from modules/filesystems.nix)
  systemd.tmpfiles.rules = [
    "d /var/lib/ssh 0755 root root -"
    "d /var/lib/lact 0755 root root -"
  ];
  environment.etc."lact".source = "/var/lib/lact";
  services.openssh.hostKeys = [
    {
      path = "/var/lib/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  environment.etc."avahi/services/.keep".text = ""; # https://github.com/nixos/nixpkgs/issues/539763
}
