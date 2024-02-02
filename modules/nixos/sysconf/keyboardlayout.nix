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
        default = false;
        description = ''
          Enable dvorak layout
        '';
      };
      graphite = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable graphite layout
        '';
      };
      swapkeys = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Ctrl instead of caps, swap Super and Alt
        '';
      };
    };
  };
  config = {
    # Configure console keymap
    # console.keymap = "dvorak";
    # services.kmscon.extraConfig = ''
    #   xkb-layout=us
    #   xkb-variant=dvorak
    # '';
    console.useXkbConfig = mkIf config.keyboardlayout.graphite true;
    services.xserver.xkb.extraLayouts.graphite = mkIf config.keyboardlayout.graphite {
      description = "Graphite";
      languages = ["eng"];
      symbolsFile = ./graphite.xkb;
    };
    services.xserver.xkb.layout = mkIf config.keyboardlayout.graphite "graphite";

    services.kanata = mkIf config.keyboardlayout.graphite {
      enable = true;
      keyboards.graphite.config = ''
        (defsrc
          grv  1     2    3    4    5    6     7    8    9    0    -    =    bspc
          tab  q     w    e    r    t    y     u    i    o    p    [    ]    \
          caps a     s    d    f    g    h     j    k    l    ;    '    ret
          lsft z     x    c    v    b    n     m    ,    .    /    rsft
          lctl lmet  lalt          spc              ralt rmet rctl
        )

        (deflayer graphite
          grv  1     2    3    4    5    6     7    8    9    0    [    ]    C-bspc
          tab  b     l    d    w    z    @'    f    o    u    j    ;    =    \
          @ctl n     r    t    s    g    y     h    a    e    i    @,   ret
          lsft x     m    c    v    q    k     p    .    @-   @/   rsft
          @ctl lmet  lalt          spc              ralt @rmet rctl
        )

        (defalias
          rmet (layer-toggle nav)
          ctl (tap-hold-press 200 200 bspc lctl)
          ' (fork ' - (lsft rsft))
          , (fork , / (lsft rsft))
          - (fork - ' (lsft rsft))
          / (fork / , (lsft rsft))
        )

        (deflayer nav
          _    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  _
          _    _    _    _    _    _    _    del  esc  _    _    _    _    _
          _    _    _    home end  _    left down up   rght _    _    _
          _    _    _    _    _    _    _    _    _    _    _    _
          _    _    _              _              _    _    _
        )
      '';
    };
  };
}
