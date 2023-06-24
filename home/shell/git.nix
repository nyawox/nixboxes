{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.git;
in
{
  options = {
    modules.shell.git = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;

      extraConfig = {
        pull.rebase = false;
        credential.helper = "libsecret"; # required for obsidian-git plugin
        init.defaultBranch = "main";
        core.symlinks = false;
        transfer.fsckobjects = true;
        fetch.fsckobjects = true;
        receive.fsckobjects = true;
      };

      userEmail = "nyawox.git@gmail.com";
      userName = "nyawox";
    };
  };
}
