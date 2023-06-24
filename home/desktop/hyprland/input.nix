{
  lib,
  osConfig,
  ...
}: {
  wayland.windowManager.hyprland.extraConfig = lib.mkIf osConfig.keyboardlayout.dvorak ''
    input {
        kb_layout = us
        kb_variant = dvorak
    }
  '';
}
