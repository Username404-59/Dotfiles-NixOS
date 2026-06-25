{ ... }:

{
  security.rtkit.enable = true; # Improves pipewire audio latency
  services.pipewire = {
    # For LMMS:
    jack.enable = true;
  };
}