{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    home = "/var/lib/ollama";
    host = "127.0.0.1";
    port = 11434;
    package = pkgs.ollama-cuda;
    # package = pkgs.ollama-vulkan;
    loadModels = [
      "deepseek-r1:8b"
      "qwen3.5:9b"
      "baytout3/qwen3.5-uncensored:9b"
      "nandhank/qwen3.5-abliterated-truthful:9b"
      "gemma4:e4b"
      "joe-speedboat/Gemma-4-Uncensored-HauhauCS-Aggressive:e4b"

      # Good at coding
      "rafw007/qwen35-claude-coder:9b"
      # "hf.co/DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF:Q4_K_M"

      # Minecraft
      "sweaterdog/andy-4:q5_k_m"
      "nomic-embed-text"
    ];
    syncModels = true;
  };
  # nix.settings = {
  #   substituters = [ "https://cache.nixos-cuda.org" ];
  #   trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  # };
}
