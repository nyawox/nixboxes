{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.adguardhome;
in {
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
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [53];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [53];
    # adguardhome conflicts with resolved
    services.resolved.enable = mkForce false;
    services.adguardhome = {
      enable = true;
      allowDHCP = true;
      port = 3380;
      mutableSettings = false;
      settings = {
        dns = {
          upstream_dns = ["9.9.9.9"];
          bootstrap_dns = ["9.9.9.9"];
          fallback_dns = ["149.112.112.112"];
          enable_dnssec = true;
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
        };
        statistics.enabled = true;
        querylog.enabled = true;
        tls.enabled = true;
        user_rules = [
          "@@||*nixlap.top^"
          "@@||*tailscale.com"
          "@@||*instagram.com"
        ];
        filters =
          imap (index: elem: {
            enabled = true;
            name = toString index;
            id = index;
            url = elem;
          })
          [
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt" # HaGeZi's Pro Plus DNS Blocklist
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt" # HaGeZi's Threat Intelligence Feeds DNS Blocklist
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/doh-vpn-proxy-bypass.txt" # HaGeZi's DoH/VPN/TOR/Proxy Bypass DNS Blocklist
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/fake.txt" # HaGeZi's Fake DNS Blocklist
            "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt" # AdGuard DNS filter
            "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/MobileFilter/sections/specific_app.txt" # AdGuard MobileFilter
            "https://adaway.org/hosts.txt" # AdAway Default Blocklist
            "https://someonewhocares.org/hosts/zero/hosts" # Dan Pollock's List
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt" # WindowsSpyBlocker - Hosts spy rules
            "https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/adguard.txt" # Scam Blocklist by DurableNapkin
            "https://raw.githubusercontent.com/mitchellkrogza/The-Big-List-of-Hacked-Malware-Web-Sites/master/hosts" # The Big List of Hacked Malware Web Sites
            "https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-agh.txt" # Online Malicious URL Blocklist (AdGuard Home)
            "https://raw.githubusercontent.com/ABPindo/indonesianadblockrules/master/subscriptions/abpindo.txt" # IDN: ABPindo
            "https://raw.githubusercontent.com/yous/YousList/master/hosts.txt" # KOR: YousList
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/NorwegianExperimentalList%20alternate%20versions/NordicFiltersAdGuardHome.txt" # NOR: Dandelion Sprouts nordiske filtre
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt" # Dandelion Sprout's Anti-Malware List (for AdGuard Home, and for AdGuard for Android/Windows' DNS filtering)
            "https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile.txt" # POL: Polish filters for Pi hole
            "https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt" # SWE: Frellwit's Swedish Hosts File
            "https://anti-ad.net/easylist.txt" # CHN: anti-AD
            "https://easylist-downloads.adblockplus.org/easylistdutch.txt" # NLD: Easylist
            "https://raw.githubusercontent.com/DRSDavidSoft/additional-hosts/master/domains/blacklist/unwanted-iranian.txt" # IRN: Unwanted Iranian domains
            "https://raw.githubusercontent.com/cchevy/macedonian-pi-hole-blocklist/master/hosts.txt" # MKD: Macedonian Pi-hole Blocklist
            "https://paulgb.github.io/BarbBlock/blacklists/hosts-file.txt" # BarbBlock
            "https://winhelp2002.mvps.org/hosts.txt" # Winhelp MVPS Hosts
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt" # uBlock filters - Default
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt" # uBlock filters – Badware risks
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt" # uBlock filters – Privacy
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt" # uBlock filters – Resource abuse
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt" # uBlock filters – Unbreak
            "https://big.oisd.nl" # OISD Big List
            "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt" # Lightswitch05 - Ads and Tracking
            "https://www.github.developerdan.com/hosts/lists/facebook-extended.txt" # Lightswitch05 - Facebook
            "https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt" # Lightswitch05 - AMP Hosts
            "https://www.github.developerdan.com/hosts/lists/dating-services-extended.txt" # Lightswitch05 - Dating Services
            "https://www.github.developerdan.com/hosts/lists/tracking-aggressive-extended.txt" # Lightswitch05 - Tracking Aggressive
            "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt" # PolishFiltersTeam - KADhosts
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts" # FadeMind - Hosts Extra (Spam Hosts)
            "https://v.firebog.net/hosts/static/w3kbl.txt" # Firebog - Personal Blocklist by WaLLy3K
            "https://v.firebog.net/hosts/neohostsbasic.txt" # Firebog - Neohostsbasic
            "https://v.firebog.net/hosts/AdguardDNS.txt" # Firebog - AdGuardDNS
            "https://v.firebog.net/hosts/Admiral.txt" # Firebog - Admiral
            "https://v.firebog.net/hosts/Easylist.txt" # Firebog - Easylist
            "https://v.firebog.net/hosts/Prigent-Crypto.txt" # Firebog - Prigent Crypto
            "https://v.firebog.net/hosts/Prigent-Malware.txt" # Firebog - Prigent Malware
            "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt" # Matomo - Referrer Spam Blacklist
            "https://raw.githubusercontent.com/matomo-org/referrer-spam-list/master/spammers.txt" # Matomo.org - Referrer Spammers
            "https://raw.githubusercontent.com/VeleSila/yhosts/master/hosts" # VeleSila - yhosts
            "https://raw.githubusercontent.com/RooneyMcNibNug/pihole-stuff/master/SNAFU.txt" # RooneyMcNibNug - PiHole Stuff (SNAFU)
            "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt" # anudeepND - Adservers
            "https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt" # anudeepND - Facebook
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt" # Ad filter list by Disconnect
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext" # Peter Lowe's List
            "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV-AGH.txt" # Perflyst and Dandelion Sprout's Smart-TV Blocklist
            "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt" # Spam404 - Main Blacklist
            "https://raw.githubusercontent.com/Spam404/lists/master/adblock-list.txt" # Spam404 - Adblock List
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/GameConsoleAdblockList.txt" # Game Console Adblock List
            "https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt" # NoCoin Filter Lis
            "https://abpvn.com/android/abpvn.txt" # VNM: ABPVN List
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts" # FadeMind - UncheckyAds
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts" # FadeMind - Additional Risks
            "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts" # bigdargon - hostsVN
            "https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts" # jdlingyu - ad-wars
            "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt" # Threat-Intel
            "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt" # ethanr - DNS-Blacklists
            "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt" # NoTrack Malware Blocklist
            "https://urlhaus.abuse.ch/downloads/hostfile/" # abuse.ch URLhaus Host file
            "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser" # ZeroDot1 - CoinBlockerLists
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" # StevenBlack - Hosts
            "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt" # Adblock Warning Removal List
            "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt" # ABP filters
            "https://raw.githubusercontent.com/AdguardTeam/cname-trackers/master/data/combined_disguised_trackers.txt" # AdGuard CNAME disguised trackers list
            "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt" # Fanboy’s Annoyance List - Anti-Cookie
            "https://easylist.to/easylist/easyprivacy.txt" # EasyPrivacy
            "https://raw.githubusercontent.com/nextdns/cname-cloaking-blocklist/master/domains" # NextDNS - CNAME cloaking blocklist
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/alexa" # NextDNS - Native Tracking Domains (Alexa)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/apple" # NextDNS - Native Tracking Domains (Apple)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/huawei" # NextDNS - Native Tracking Domains (Huawei)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/roku" # NextDNS - Native Tracking Domains (Roku)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/samsung" # NextDNS - Native Tracking Domains (Samsung)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/sonos" # NextDNS - Native Tracking Domains (Sonos)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/windows" # NextDNS - Native Tracking Domains (Windows)
            "https://raw.githubusercontent.com/nextdns/native-tracking-domains/main/domains/xiaomi" # NextDNS - Native Tracking Domains (Xiaomi)
            "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt" # FrogEye - FirstParty Trackers Hosts List
            "https://v.firebog.net/hosts/Easyprivacy.txt" # Firebog - Easyprivacy
            "https://v.firebog.net/hosts/Prigent-Ads.txt" # Firebog - Prigent Ads
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts" # FadeMind - 2o7Net
            "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt" # Malvertising filter list by Disconnect
            "https://malware-filter.gitlab.io/malware-filter/phishing-filter-agh.txt" # Online Phishing URL Blocklist (AdGuard Home)
            "https://dl.red.flag.domains/red.flag.domains.txt" # Red Flag Domains
            "https://raw.githubusercontent.com/eEIi0A5L/adblock_filter/master/all.txt" # JPN: Mochi Filter
            "https://raw.githubusercontent.com/tofukko/filter/master/Adblock_Plus_list.txt" # JPN: Tofu Filter
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt" # URL Shortener
          ];
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable (singleton {
      directory = "/var/lib/private/AdGuardHome";
      user = "adguardhome";
      group = "adguardhome";
      mode = "750";
    });
  };
}
