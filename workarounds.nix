{ ... }:

let
  dirs = {
    ssh = "/var/lib/ssh";
  };
in
{
  documentation.nixos.enable = false; # In case something's documentation is making nixos-rebuild fail

  # Fixes for things broken by system.etc.overlay.mutable (from modules/filesystems.nix)
  systemd.tmpfiles.rules = [
    "d ${dirs.ssh} 0755 root root -"
  ];
  services.openssh.hostKeys = [
    {
      path = "${dirs.ssh}/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  boot.kernelParams = [ "systemd.machine_id=firmware" ]; # Needed for persistent journalctl
}
