{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.desktop.zathura;
in
{
  options = {
    modules.desktop.zathura = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      extraConfig = ''
        include catppuccin-mocha
        set selection-clipboard clipboard
        set default-bg rgba(30,30,46,0.98)
        set recolor-lightcolor rgba(0,0,0,0)
        set font "Fast_Serif 16"
      '';
    };

    xdg = {
      configFile."zathura/catppuccin-mocha".source =
        inputs.catppuccin-zathura.outPath + "/src/catppuccin-mocha";
      mimeApps.defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      };
    };
  };
}
