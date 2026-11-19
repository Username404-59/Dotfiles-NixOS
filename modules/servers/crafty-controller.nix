{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/crafty";
in
{
  # For default credentials: sudo cat /var/lib/crafty/config/default-creds.txt
  virtualisation.oci-containers.containers.crafty = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:4.11.1";
    autoStart = true;

    environment = {
      TZ = config.time.timeZone;
    };

    ports = [
       "8443:8443"                      # Web UI (HTTPS)
       "8100-8200:8100-8200"            # BlueMap
       "8723:8723"                      # Colonyweb
       "19132:19132/udp"                # Bedrock
       "24454:24454/udp"                # Simple Voice Chat
       "25500-25600:25500-25600"        # Minecraft server port range
    ];

    volumes = [
      "${dataDir}/backups:/crafty/backups"
      "${dataDir}/logs:/crafty/logs"
      "${dataDir}/servers:/crafty/servers"
      "${dataDir}/config:/crafty/app/config"
      "${dataDir}/import:/crafty/import"
    ];
  };

  # Persistent data directories
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 root root - -"
    "Z ${dataDir}/backups 0755 1000 0 - -"
    "Z ${dataDir}/logs    0755 1000 0 - -"
    "Z ${dataDir}/servers 0755 1000 0 - -"
    "Z ${dataDir}/config  0755 1000 0 - -"
    "Z ${dataDir}/import  0755 1000 0 - -"
  ];

  networking.firewall = let
    mc_ports = { from = 25500; to = 25600; };
  in {
    allowedTCPPorts = [ 8443 8723 ];
    allowedUDPPorts = [ 19132 24454 ];
    allowedUDPPortRanges = [ mc_ports ];
    allowedTCPPortRanges = [
      mc_ports
      { from = 8100; to = 8200; }
    ];
  };
}