{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.aichat;
in
{
  options = {
    modules.shell.aichat = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.aichat ];
    xdg.configFile."aichat/config.yaml".text =
      # yaml
      ''
        model: ollama:${osConfig.modules.services.ollama.chatModel}
        clients:
        - type: openai-compatible
          name: ollama
          api_base: http://lolcathost.hsnet.nixlap.top:11434/v1
          models:
          - name: ${osConfig.modules.services.ollama.chatModel}
            max_input_tokens: 8192
          - name: ${osConfig.modules.services.ollama.codingModel}
            max_input_tokens: 16384
      '';
  };
}
