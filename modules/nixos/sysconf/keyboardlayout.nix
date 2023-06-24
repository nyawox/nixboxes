{
  config,
  lib,
  ...
}:
with lib; {
  options = {
    keyboardlayout = {
      dvorak = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable dvorak layout
        '';
      };
    };
  };
  config = {
    # Configure console keymap
    console.keyMap = mkIf config.keyboardlayout.dvorak "dvorak";
    services.kmscon.extraConfig = mkIf config.keyboardlayout.dvorak ''
      xkb-layout=us
      xkb-variant=dvorak
    '';
  };
}
