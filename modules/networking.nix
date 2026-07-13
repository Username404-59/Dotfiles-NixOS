{ isLaptop, ... }:

{
  # Enable networking
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    wireless.iwd.settings = {
      General = {
        AddressRandomization = "once";
      };
      Network = {
        EnableIPv6 = true;
      };
      Settings = {
        AutoConnect = true;
      };
      Rank = {
        BandModifier2_4GHZ = 1.0;
        BandModifier5GHZ = 1.1;
        BandModifier6GHZ = 2.0;
      };
    };

    firewall = {
      allowedTCPPorts = [
        57621 # Spotify discovery port
        25565 # Minecraft
        7777 7778 27016
        8080 # Dev test port
      ];
      allowedUDPPorts = [
        5353 # Spotify discovery port
        7777 7778 27016 # Satisfactory dedicated server (etc) ports
        8080
      ];
    };

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.blueman.enable = true;
}
