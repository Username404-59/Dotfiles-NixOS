{ pkgs, config, isLaptop, ... }:

{
  services.ollama = {
    enable = !isLaptop;
    package = pkgs.ollama-vulkan;

    loadModels = [
      "qwen3.5:9b"
    ];

    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768";
    };
  };

  services.open-webui = {
    enable = config.services.ollama.enable;
    port = 6767;
    openFirewall = false;
    environment = rec {
      WEBUI_AUTH = "False"; # No need for auth since it's only accessible by me
      OFFLINE_MODE = "True"; # Update checks & model downloads aren't needed
      SAFE_MODE = "True";
      BYPASS_MODEL_ACCESS_CONTROL = "True";
      ENABLE_COMPRESSION_MIDDLEWARE = "False"; # Not needed since I access it via localhost
      #ENABLE_PERSISTENT_CONFIG = "False";
      #OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
      #GGML_VK_VISIBLE_DEVICES = "0";

      DEFAULT_MODELS = builtins.concatStringsSep ", " config.services.ollama.loadModels;
      DEFAULT_PINNED_MODELS = DEFAULT_MODELS;
    };
  };

  /* TODO: Uncomment when odysseus package supports non-flake installation (& disable open-webui)
  services.odysseus = {
    enable = config.services.ollama.enable;
    xdg.dataHome."odysseus/odysseus-env".source = ./odysseus/.env;
    # https://github.com/pewdiepie-archdaemon/odysseus/blob/dev/.env.example
    environmentFile = "${config.xdg.dataHome}}/odysseus/odysseus-env";
    host = "127.0.0.1";
    port = 6767;
  };
  */
}