{ vars, ... }:
{
  home-manager.users.${vars.username} = {
    programs.claude-code = {
      enable = true;
      settings = {
        env = {
          ANTHROPIC_BASE_URL = "http://127.0.0.1:9090";
          ANTHROPIC_AUTH_TOKEN = "strata-local";
          ANTHROPIC_MODEL = "qwen3.8-flash-next-gyro-gyro-m";
          ANTHROPIC_SMALL_FAST_MODEL = "qwen3.8-flash-next-gyro-gyro-m";
          ANTHROPIC_DEFAULT_SONNET_MODEL = "qwen3.8-flash-next-gyro-gyro-m";
          ANTHROPIC_DEFAULT_OPUS_MODEL = "qwen3.8-flash-next-gyro-gyro-m";
          ANTHROPIC_DEFAULT_HAIKU_MODEL = "qwen3.8-flash-next-gyro-gyro-m";
          CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          CLAUDE_CODE_MAX_CONTEXT_TOKENS = "131072";
          CLAUDE_CODE_MAX_OUTPUT_TOKENS = "16384";
        };
      };
    };
  };
}
