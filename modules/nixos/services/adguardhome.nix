{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.adguardhome;
in
{
  options = {
    modules.services.adguardhome = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      openFirewall = mkOption {
        # Open port 53 for local use
        type = types.bool;
        default = false;
      };
      noLog = mkOption {
        type = types.bool;
        default = false;
      };
      slowMode = mkOption {
        # disable upstream with fast response time to make slow, useful for fallback dns. the behaviour depends on os implementation
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 53 ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 53 ];
    # adguardhome conflicts with resolved
    services.resolved.enable = mkForce false;
    services.adguardhome = {
      enable = true;
      allowDHCP = true;
      port = 3380;
      mutableSettings = false;
      settings = {
        dns = {
          ratelimit = 0;
          upstream_code = "parallel";
          upstream_dns = [
            (mkIf (!cfg.slowMode) "https://dns.quad9.net/dns-query")
            "https://se-sto-dns-001.mullvad.net/dns-query"
            "https://se-mma-dns-001.mullvad.net/dns-query"
            "https://se-got-dns-001.mullvad.net/dns-query"
          ];
          bootstrap_dns = [
            "76.76.2.0"
            "76.76.10.0"
            "2606:1a40::"
            "2606:1a40:1::"
          ]; # controld
          use_http3_upstreams = true;
          serve_http3 = true;
          enable_dnssec = true;

          cache_optimistic = true;
          cache_size = 500000000; # 500 megabytes in bytes
          cache_ttl_min = 86400; # 24 hours in seconds
          cache_ttl_max = 172800; # 48 hours in seconds
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          blocking_mode = "null_ip";
          filters_update_interval = 24;
        };
        statistics = {
          enabled = mkIf cfg.noLog false;
          interval = "720h"; # 30days
        };
        querylog = {
          enabled = mkIf cfg.noLog false;
          size_memory = 50;
          interval = "720h"; # 30days
        };
        tls.enabled = true;
        user_rules = [
          "@@||*nixlap.top^"
          "@@||*tailscale.com"
          "@@||*instagram.com"
          "@@||*z-lib*"
          "@@||*fmhy.net"
          "@@||p1bizprd.ukw.jp^" # daiso
          "@@||s3bizprd.ukw.jp^" # daiso
          "@@||mask.icloud.com" # private relay
          "@@||mask-h2.icloud.com"
          "@@||apple-relay.cloudflare.com"
          "@@||apple-relay.fastly-edge.com"
          "@@||instagram.fngo3-1.fna.fbcdn.net" # it may also be involved in tracking but blocking make instagram hella slow.
          "@@||*mullvad.net^" # mullvad
          "@@||*protonvpn.com^" # proton vpn
          "@@||youtube.com^"
          # siri?
          "||gdmf.v.aaplimg.com"
          "||gdmf-ados.v.aaplimg.com"
          "||seed-siri-apple-com.v.aaplimg.com"
          # baidu sht
          "||statis.simeji.me^"
        ];
        filters =
          imap
            (index: elem: {
              enabled = true;
              name = toString index;
              id = index;
              url = elem;
            })
            [
              "https://big.oisd.nl" # OISD Big List
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt" # HaGeZi's Ultimate DNS Blocklist
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt" # HaGeZi's Threat Intelligence Feeds DNS Blocklist
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/doh-vpn-proxy-bypass.txt" # HaGeZi's DoH/VPN/TOR/Proxy Bypass DNS Blocklist
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/dyndns.txt" # HaGeZi's DynDNS Blocklist
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/hoster.txt" # HaGeZi's Badware Hoster DNS Blocklist
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/GameConsoleAdblockList.txt" # Game Console Adblock List
              "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/refs/heads/master/SmartTV-AGH.txt" # Smart-TV Blocklist for AdGuard Home (by Dandelion Sprout)
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-referral.txt" # HaGeZi's Allowlist Referral
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt" # URL Shortener
            ];
      };
    };

    systemd.services.adguardhome.serviceConfig = {
      Nice = mkForce (-20);
      IOWeight = mkForce 10000;
      CPUWeight = mkForce 10000;
    };
    environment.persistence."/persist".directories =
      mkIf (config.modules.sysconf.impermanence.enable && !cfg.noLog)
        (singleton {
          directory = "/var/lib/private/AdGuardHome";
          user = "adguardhome";
          group = "adguardhome";
          mode = "750";
        });
  };
}
