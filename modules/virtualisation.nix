{ ... }:

{
  virtualisation = {
    virtualbox.host = rec {
      enable = true;
      enableExtensionPack = false;
      enableKvm = true;
      addNetworkInterface = !enableKvm;
      enableHardening = !enableKvm;
    };

    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    oci-containers.backend = "podman";
  };
}