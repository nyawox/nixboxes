{
  lib,
  config,
  pkgs,
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
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        libsForQt5.fcitx5-qt
        catppuccin-fcitx5
      ];
    };

    xdg.configFile = {
      "fcitx5/profile" = {
        force = true;
        text = ''
          [Groups/0]
          # Group Name
          Name=Default
          # Layout
          Default Layout=us
          # Default Input Method
          DefaultIM=mozc

          [Groups/0/Items/0]
          # Name
          Name=keyboard-us
          # Layout
          Layout=

          [Groups/0/Items/1]
          # Name
          Name=mozc
          # Layout
          Layout=

          [GroupOrder]
          0=Default
        '';
      };

      "fcitx5/config" = {
        force = true;
        text = ''
          [Hotkey]
          # Enumerate when press trigger key repeatedly
          EnumerateWithTriggerKeys=True
          # Enumerate Input Method Forward
          EnumerateForwardKeys=
          # Enumerate Input Method Backward
          EnumerateBackwardKeys=
          # Skip first input method while enumerating
          EnumerateSkipFirst=False

          [Hotkey/TriggerKeys]
          0=Control+Shift+space
          1=Zenkaku_Hankaku
          2=Hangul

          [Hotkey/AltTriggerKeys]
          0=Shift_L

          [Hotkey/EnumerateGroupForwardKeys]
          0=Super+space

          [Hotkey/EnumerateGroupBackwardKeys]
          0=Shift+Super+space

          [Hotkey/ActivateKeys]
          0=Hangul_Hanja

          [Hotkey/DeactivateKeys]
          0=Hangul_Romaja

          [Hotkey/PrevPage]
          0=Up

          [Hotkey/NextPage]
          0=Down

          [Hotkey/PrevCandidate]
          0=Shift+Tab

          [Hotkey/NextCandidate]
          0=Tab

          [Hotkey/TogglePreedit]
          0=Control+Alt+P

          [Behavior]
          # Active By Default
          ActiveByDefault=False
          # Share Input State
          ShareInputState=No
          # Show preedit in application
          PreeditEnabledByDefault=True
          # Show Input Method Information when switch input method
          ShowInputMethodInformation=True
          # Show Input Method Information when changing focus
          showInputMethodInformationWhenFocusIn=False
          # Show compact input method information
          CompactInputMethodInformation=True
          # Show first input method information
          ShowFirstInputMethodInformation=True
          # Default page size
          DefaultPageSize=5
          # Override Xkb Option
          OverrideXkbOption=False
          # Custom Xkb Option
          CustomXkbOption=
          # Force Enabled Addons
          EnabledAddons=
          # Force Disabled Addons
          DisabledAddons=
          # Preload input method to be used by default
          PreloadInputMethod=True
        '';
      };

      "fcitx5/conf/classicui.conf" = {
        force = true;
        text = ''
          # Vertical Candidate List
          Vertical Candidate List=False
          # Use mouse wheel to go to prev or next page
          WheelForPaging=True
          # Font
          Font="IBM Plex Sans 10"
          # Menu Font
          MenuFont="IBM Plex Sans 10"
          # Tray Font
          TrayFont="IBM Plex Sans 10"
          # Tray Label Outline Color
          TrayOutlineColor=#000000
          # Tray Label Text Color
          TrayTextColor=#ffffff
          # Prefer Text Icon
          PreferTextIcon=False
          # Show Layout Name In Icon
          ShowLayoutNameInIcon=True
          # Use input method language to display text
          UseInputMethodLanguageToDisplayText=True
          # Theme
          Theme=catppuccin-mocha
          # Dark Theme
          DarkTheme=catppuccin-mocha
          # Follow system light/dark color scheme
          UseDarkTheme=True
          # Follow system accent color if it is supported by theme and desktop
          UseAccentColor=True
          # Use Per Screen DPI on X11
          PerScreenDPI=False
          # Force font DPI on Wayland
          ForceWaylandDPI=0
          # Enable fractional scale under Wayland
          EnableFractionalScale=True
        '';
      };
    };
  };
}
