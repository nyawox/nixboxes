{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.shell.aichat;
in {
  options = {
    modules.shell.aichat = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [pkgs.aichat];
    xdg.configFile."aichat/config.yaml".text =
      /*
      yaml
      */
      ''
        model: ollama
        clients:
        - type: ollama
          api_base: http://localpost.nyaa.nixlap.top:11451
          api_auth: null
          models:
          - name: mistral-nemo:12b-instruct-2407-q4_K_M
            max_input_tokens: 128000
          - name: deepseek-coder-v2:16b-lite-base-q4_K_M
            max_input_tokens: 8192
      '';
  };
}
