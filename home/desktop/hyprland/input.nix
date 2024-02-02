{
  lib,
  osConfig,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf osConfig.keyboardlayout.dvorak {
    input = {
      kb_layout = "us";
      kb_variant = "dvorak";
      kb_options = lib.mkIf osConfig.keyboardlayout.swapkeys "ctrl:nocaps,altwin:swap_alt_win";
    };
  };
}
