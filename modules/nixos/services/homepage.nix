{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.homepage;
in {
  options = {
    modules.services.homepage = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      openFirewall = false;
    };

    environment.persistence."/persist".directories = lib.mkIf config.modules.sysconf.impermanence.enable ["/var/lib/private/homepage-dashboard/logs"];

    # Symlink configs to correct directory
    systemd.tmpfiles.rules = [
      "C /var/lib/private/homepage-dashboard/bookmarks.yaml 0600 root root - /etc/private/homepage-dashboard/bookmarks.yaml"
      "C /var/lib/private/homepage-dashboard/services.yaml 0600 root root - /etc/private/homepage-dashboard/services.yaml"
      "C /var/lib/private/homepage-dashboard/settings.yaml 0600 root root - /etc/private/homepage-dashboard/settings.yaml"
      "C /var/lib/private/homepage-dashboard/widgets.yaml 0600 root root - /etc/private/homepage-dashboard/widgets.yaml"
    ];

    environment.etc = {
      "private/homepage-dashboard/bookmarks.yaml".text = ''
        ---
        # For configuration options and examples, please see:
        # https://gethomepage.dev/en/configs/bookmarks
        - Search Engine:
            - Search:
                - abbr: S
                  href: https://search.nixhome.shop
                  icon: https://search.nixhome.shop/static/themes/simple/img/searxng.png
            - NixOS Search:
                - abbr: NS
                  href: https://search.nixos.org/packages
                  icon: https://nixos.org/logo/nix-wiki.png
            - Google:
                - abbr: G
                  href: https://www.google.com
                  icon: https://upload.wikimedia.org/wikipedia/commons/2/2d/Google-favicon-2015.png
            - Yandex Image:
                - abbr: YI
                  href: https://yandex.ru/images/
                  icon: https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Yandex_icon.svg/480px-Yandex_icon.svg.png
        - Developer:
            - Github:
                - abbr: GH
                  href: https://github.com/
                  icon: https://cdn-icons-png.flaticon.com/512/25/25231.png
            - NixOS Wiki:
                - abbr: NW
                  href: https://nixos.wiki/
                  icon: https://nixos.wiki/images/thumb/2/20/Home-nixos-logo.png/207px-Home-nixos-logo.png
            - Nixpkgs Pull Request Tracker:
                - abbr: NPR
                  href: https://nixpk.gs/pr-tracker.html
                  icon: https://nixos.org/logo/nix-wiki.png
            - Nixpkgs:
                - abbr: NP
                  href: https://github.com/NixOS/nixpkgs
                  icon: https://nixos.org/logo/nix-wiki.png
            - Arch Wiki:
                - abbr: AW
                  href: https://wiki.archlinux.org/
                  icon: https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://wiki.archlinux.org&size=128
            - ChatGPT:
                - abbr: CG
                  href: https://chat.openai.com/
                  icon: https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/ChatGPT_logo.svg/768px-ChatGPT_logo.svg.png

        - Social:
            - Reddit:
                - abbr: RE
                  href: https://reddit.com/
                  icon: https://www.iconpacks.net/icons/2/free-reddit-logo-icon-2436-thumb.png
            - Twitter:
                - abbr: X
                  href: https://twitter.com/
                  icon: https://cdn-icons-png.flaticon.com/512/889/889147.png
            - Instagram:
                - abbr: INS
                  href: https://www.instagram.com/
                  icon: https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png?20200512141346
            - Proton Mail:
                - abbr: PM
                  href: https://account.proton.me/mail
                  icon: https://play-lh.googleusercontent.com/99IPL5W1HvN1TM7awcJ2gihUie-LQ5Ae7W9g0FgCBFJ8hNZnFIOJElyBPNcx4Wcx7A

        - Entertainment:
            - YouTube:
                - abbr: YT
                  href: https://youtube.com/
                  icon: https://www.iconpacks.net/icons/2/free-youtube-logo-icon-2431-thumb.png
            - Twitch:
                - abbr: TW
                  href: https://www.twitch.tv/
                  icon: https://cdn-icons-png.flaticon.com/512/5968/5968819.png
            - Netflix:
                - abbr: NT
                  href: https://www.netflix.com/
                  icon: https://dwglogo.com/wp-content/uploads/2019/02/netflix_emblem_transparent-1024x854.png
            - Prime Video:
                - abbr: PV
                  href: https://www.amazon.co.jp/gp/video/getstarted
                  icon: https://www.svgrepo.com/show/494362/amazon.svg
      '';
      "private/homepage-dashboard/services.yaml".text = ''
        ---
        # For configuration options and examples, please see:
        # https://gethomepage.dev/latest/configs/services

        - Home:
            - Home Assistant:
                href: http://nixpro64.nyaa.nixhome.shop:8123/
                icon: https://cdn.icon-icons.com/icons2/2107/PNG/512/file_type_homeassistant_icon_130543.png
            - Node-RED:
                href: http://nixpro64.nyaa.nixhome.shop:1880/
                icon: https://nodered.org/about/resources/media/node-red-icon.svg

        - Monitoring:
            - Grafana:
                href: http://vultr.nyaa.nixhome.shop:3042/
                icon: https://cdn.icon-icons.com/icons2/2699/PNG/512/grafana_logo_icon_171048.png
            - Prometheus:
                href: http://vultr.nyaa.nixhome.shop:9001/
                icon: https://cdn.icon-icons.com/icons2/3914/PNG/512/prometheus_logo_icon_248769.png

        - Tools:
            - Transmissionic:
                href: http://tomoyo.nyaa.nixhome.shop:9091/
                icon: https://github.com/6c65726f79/Transmissionic/blob/main/public/assets/icon/favicon.png?raw=true
            - Sunshine:
                href: https://lolcathost.nyaa.nixhome.shop:47990/
                icon: https://raw.githubusercontent.com/LizardByte/Sunshine/nightly/src_assets/common/assets/web/images/logo-sunshine-45.png
            - Vaultwarden:
                href: https://vault.nixhome.shop/
                icon: https://raw.githubusercontent.com/dani-garcia/vaultwarden/main/resources/vaultwarden-icon.svg
            - Linkding:
                href: https://linkding.nixhome.shop/
                icon: https://linkding.nixhome.shop/static/logo.png
      '';
      "private/homepage-dashboard/widgets.yaml".text = ''
        - logo:
            icon: https://camo.githubusercontent.com/8c73ac68e6db84a5c58eef328946ba571a92829b3baaa155b7ca5b3521388cc9/68747470733a2f2f692e696d6775722e636f6d2f367146436c41312e706e67
        - resources: false
        - datetime:
            text_size: 3x1
            format:
              timeStyle: short
              dateStyle: short
              hourCycle: h23
        - search:
            provider: custom
            url: https://search.nixhome.shop/search?q=
            focus: false
            target: _blank
        - openmeteo:
            label: Weather
            timezone: Asia/Tokyo
            units: metric
            cache: 5 # Time in minutes to cache API responses, to stay within limits
      '';
      "private/homepage-dashboard/settings.yaml".text = ''
        title: Homepage
        background:
          image: https://raw.githubusercontent.com/Gingeh/wallpapers/main/minimalistic/hearts.png
        cardBlur: xl
        theme: dark
        color: slate
        favicon: https://camo.githubusercontent.com/8c73ac68e6db84a5c58eef328946ba571a92829b3baaa155b7ca5b3521388cc9/68747470733a2f2f692e696d6775722e636f6d2f367146436c41312e706e67
        hideVersion: true
        headerStyle: underlined
      '';
    };
  };
}
