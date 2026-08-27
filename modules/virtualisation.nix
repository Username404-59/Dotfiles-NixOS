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

    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;
      };

      daemon.settings = {
        experimental = true;
        storage-driver = "overlay2";
      };

      autoPrune.enable = true;
    };
  };
}