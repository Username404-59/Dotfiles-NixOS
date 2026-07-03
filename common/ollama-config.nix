{ pkgs, config, isLaptop, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;

    loadModels = [
      (if isLaptop then "qwen3.5:9b" else "qwen3.6:27b")
    ];
  };

  services.open-webui = {
    enable = true;
    port = 6767;
    openFirewall = false;
    environment = rec {
      WEBUI_AUTH = "False"; # No need for auth since it's only accessible by me
      OFFLINE_MODE = "True"; # Update checks & model downloads aren't needed
      SAFE_MODE = "True";
      BYPASS_MODEL_ACCESS_CONTROL = "True";
      ENABLE_COMPRESSION_MIDDLEWARE = "False"; # Not needed since I access it via localhost
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}/v1"; # Fixes qwen 3.6 as of writing; TODO Remove if not needed anymore
      #GGML_VK_VISIBLE_DEVICES = "0";

      DEFAULT_MODELS = builtins.concatStringsSep ", " config.services.ollama.loadModels;
      DEFAULT_PINNED_MODELS = DEFAULT_MODELS;

      DEFAULT_RAG_TEMPLATE = ''
		### Task:
		Respond to the user query using the provided context, incorporating inline citations in the format [id] **only when the <source> tag includes an explicit id attribute** (e.g., <source id="1">).

		### Guidelines:
		- If you don't know the answer, clearly state that.
		- If uncertain, ask the user for clarification.
		- Respond in the same language as the user's query.
		- If the context is unreadable or of poor quality, inform the user and provide the best possible answer.
		- If the answer isn't present in the context but you possess the knowledge, explain this to the user and provide the answer using your own understanding.
		- **Only include inline citations using [id] (e.g., [1], [2]) when the <source> tag includes an id attribute.**
		- Do not cite if the <source> tag does not contain an id attribute.
		- Do not use XML tags in your response.
		- Ensure citations are concise and directly related to the information provided.

		### Example of Citation:
		If the user asks about a specific topic and the information is found in a source with a provided id attribute, the response should include the citation like in the following example:
		* "According to the study, the proposed method increases efficiency by 20% [1]."

		### Output:
		Provide a clear and direct response in the french Chtimi dialect to the user's query, including inline citations in the format [id] only when the <source> tag with id attribute is present in the context.

		<context>
		{{CONTEXT}}
		</context>
      '';
    };
  };

  /* TODO: Uncomment when odysseus package supports non-flake installation (& disable open-webui)
  services.odysseus = {
    enable = true;
    xdg.dataHome."odysseus/odysseus-env".source = ./odysseus/.env;
    # https://github.com/pewdiepie-archdaemon/odysseus/blob/dev/.env.example
    environmentFile = "${config.xdg.dataHome}}/odysseus/odysseus-env";
    host = "127.0.0.1";
    port = 6767;
  };
  */
}