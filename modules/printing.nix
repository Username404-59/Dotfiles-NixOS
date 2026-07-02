{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      # General
      cups
      cups-browsed
      cups-filters
      gutenprint # Very good drivers package
      # Canon (built from source)
      cnijfilter2
      canon-cups-ufr2
      # Brother
      brlaser #brgenml1lpr brgenml1cupswrapper
    ];
  };

  # Auto-discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # IPP-over-USB (just in case)
  services.ipp-usb.enable = true;
}