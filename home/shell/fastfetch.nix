{
  xdg.configFile."fastfetch/nixos.png".source = ../nixos.png;
  xdg.configFile."fastfetch/nixos.sixel".source = ../nixos.sixel;
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "~/.config/fastfetch/nixos.sixel",
        "type": "raw",
        "width": 50,
        "height": 20,
      },
      "modules": [
        "title",
        "separator",
        {
          "type": "os",
          "format": "{3} {12}"
        },
        {
          "type": "host",
          "format": "{/2}{-}{/}{2}{?3} {3}{?}"
        },
        "kernel",
        "uptime",
        "packages",
        "shell",
        {
          "type": "display",
          "key": "Resolution",
          "compactType": "original"
        },
        {
          "type": "de",
          "format": "{2} {3}"
        },
        "wm",
        "wmtheme",
        {
          "type": "theme",
          "format": "{?1}{1}{?3} {3}{?} [Plasma], {?}{7}"
        },
        "icons",
        "terminal",
        {
          "type": "terminalfont",
          "format": "{/2}{-}{/}{2}{?3} {3}{?}"
        },
        "cpu",
        {
          "type": "gpu",
          "forceVulkan": true
        },
        {
          "type": "memory",
          "format": "{/1}{-}{/}{/2}{-}{/}{} / {}"
        },
        "break",
        "colors"
      ]
    }
  '';
}
