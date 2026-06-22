{ pkgs, config, ... }:

{
  services.ollama = {
    enable = false; # TODO Enable when odysseus package supports non-flake installation
    package = pkgs.ollama-vulkan;
  };
  /*
  services.odysseus = {
    enable = true;
    xdg.dataHome."odysseus/odysseus-env".source = ./odysseus/.env;
    # https://github.com/pewdiepie-archdaemon/odysseus/blob/dev/.env.example
    environmentFile = "${config.xdg.dataHome}}/odysseus/odysseus-env";
    host = "127.0.0.1";
    port = 8008;
  };
  */
}