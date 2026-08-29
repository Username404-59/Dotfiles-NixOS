{ ... }:

let
  dirs = {
    ssh = "/var/lib/ssh";
    lact = "/var/lib/lact";
    nw_manager = "/var/lib/NetworkManager/system-connections";
  };
in
{
  documentation.nixos.enable = false; # In case something's documentation is making nixos-rebuild

  # TODO Remove when https://github.com/NixOS/nix/issues/5541 is fixed / https://github.com/NixOS/nix/pull/15654 is merged
  nix.settings.experimental-features = [ "flakes" ];

  # Fixes for things broken by system.etc.overlay.mutable (from modules/filesystems.nix)
  systemd.tmpfiles.rules = [
    "d ${dirs.ssh} 0755 root root -"
    "d ${dirs.lact} 0755 root root -"
    "d ${dirs.nw_manager} 0700 root root -"
  ];
  environment.etc."lact".source = dirs.lact;
  services.openssh.hostKeys = [
    {
      path = "${dirs.ssh}/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  environment.etc."avahi/services/.keep".text = ""; # https://github.com/nixos/nixpkgs/issues/539763
  networking.networkmanager.settings.keyfile.path = dirs.nw_manager;
  services.printing.stateless = true;
  services.udev.extraRules = /* Stops udisks2 from mounting loop0 */ ''
    SUBSYSTEM=="block", KERNEL=="loop*", ENV{UDISKS_IGNORE}="1"
  '';
  boot.kernelParams = [ "systemd.machine_id=firmware" ]; # Needed for persistent journalctl
}
