{
  lib,
  osConfig,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf osConfig.keyboardlayout.dvorak {
    input = {
      kb_layout = "us";
      kb_variant = "dvorak";
    };
  };
}
