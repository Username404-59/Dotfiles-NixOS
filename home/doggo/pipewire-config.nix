{ ... }:

{
  security.rtkit.enable = true; # Improves audio latency
  services.pipewire = {
    # For LMMS:
    jack.enable = true;
  };
}