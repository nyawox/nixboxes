{
  lib,
  config,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.inputmethod;
in
{
  options = {
    modules.desktop.inputmethod = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          libsForQt5.fcitx5-qt
          catppuccin-fcitx5
        ];
        waylandFrontend = true;
      };
    };
    environment.persistence."/persist".users."${username}".directories =
      mkIf config.modules.sysconf.impermanence.enable
        [
          ".config/fcitx5"
          ".config/fcitx"
        ];
  };
}
