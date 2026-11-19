{ ... }:

{
  # Enable networking
  networking = {
    useNetworkd = true;
    hostName = "stronk-lizard";
    firewall = {
      allowedTCPPorts = [
        7777 7778 27016
        8080 # Dev test port
        30309 # Port for torrents
      ];
      allowedUDPPorts = [
        7777 7778 27016 # Satisfactory dedicated server (etc) ports
        8080
        30309 # Port for torrents
      ];
    };

    stevenblack.enable = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # This makes booting faster:
  systemd.network.wait-online.enable = false;

  services.resolved.enable = true;
}
