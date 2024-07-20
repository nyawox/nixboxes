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
      bookmarks = [
        {
          "Search Engine" = [
            {
              Search = [
                {
                  abbr = "S";
                  href = "https://search.nixlap.top";
                  icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/SearXNG-wordmark.svg/1200px-SearXNG-wordmark.svg.png";
                }
              ];
            }
            {
              "NixOS Search" = [
                {
                  abbr = "NS";
                  href = "https://search.nixos.org/packages";
                  icon = "https://wiki.nixos.org/nixos.png";
                }
              ];
            }
            {
              Google = [
                {
                  abbr = "G";
                  href = "https://www.google.com";
                  icon = "https://upload.wikimedia.org/wikipedia/commons/2/2d/Google-favicon-2015.png";
                }
              ];
            }
            {
              "Yandex Image" = [
                {
                  abbr = "YI";
                  href = "https://yandex.ru/images/";
                  icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Yandex_icon.svg/480px-Yandex_icon.svg.png";
                }
              ];
            }
          ];
        }
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/";
                  icon = "https://cdn-icons-png.flaticon.com/512/25/25231.png";
                }
              ];
            }
            {
              "NixOS Wiki" = [
                {
                  abbr = "NW";
                  href = "https://wiki.nixos.org/";
                  icon = "https://wiki.nixos.org/nixos.png";
                }
              ];
            }
            {
              "Nixpkgs Pull Request Tracker" = [
                {
                  abbr = "NPR";
                  href = "https://nixpk.gs/pr-tracker.html";
                  icon = "https://wiki.nixos.org/nixos.png";
                }
              ];
            }
            {
              "Nixpkgs" = [
                {
                  abbr = "NP";
                  href = "https://github.com/NixOS/nixpkgs";
                  icon = "https://wiki.nixos.org/nixos.png";
                }
              ];
            }
            {
              "Arch Wiki" = [
                {
                  abbr = "AW";
                  href = "https://wiki.archlinux.org/";
                  icon = "https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://wiki.archlinux.org&size=128";
                }
              ];
            }
            {
              "ChatGPT" = [
                {
                  abbr = "CG";
                  href = "https://chat.openai.com/";
                  icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/ChatGPT_logo.svg/768px-ChatGPT_logo.svg.png";
                }
              ];
            }
          ];
        }
        {
          Social = [
            {
              Reddit = [
                {
                  abbr = "RE";
                  href = "https://reddit.com/";
                  icon = "https://www.iconpacks.net/icons/2/free-reddit-logo-icon-2436-thumb.png";
                }
              ];
            }
            {
              Twitter = [
                {
                  abbr = "X";
                  href = "https://twitter.com/";
                  icon = "https://cdn-icons-png.flaticon.com/512/889/889147.png";
                }
              ];
            }
            {
              Instagram = [
                {
                  abbr = "INS";
                  href = "https://www.instagram.com/";
                  icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png?20200512141346";
                }
              ];
            }
            {
              "Proton Mail" = [
                {
                  abbr = "PM";
                  href = "https://account.proton.me/mail";
                  icon = "https://play-lh.googleusercontent.com/99IPL5W1HvN1TM7awcJ2gihUie-LQ5Ae7W9g0FgCBFJ8hNZnFIOJElyBPNcx4Wcx7A";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  abbr = "YT";
                  href = "https://youtube.com/";
                  icon = "https://www.iconpacks.net/icons/2/free-youtube-logo-icon-2431-thumb.png";
                }
              ];
            }
            {
              Twitch = [
                {
                  abbr = "TW";
                  href = "https://www.twitch.tv/";
                  icon = "https://cdn-icons-png.flaticon.com/512/5968/5968819.png";
                }
              ];
            }
            {
              Netflix = [
                {
                  abbr = "NT";
                  href = "https://www.netflix.com/";
                  icon = "https://dwglogo.com/wp-content/uploads/2019/02/netflix_emblem_transparent-1024x854.png";
                }
              ];
            }
            {
              "Prime Video" = [
                {
                  abbr = "PV";
                  href = "https://www.amazon.co.jp/gp/video/getstarted";
                  icon = "https://www.svgrepo.com/show/494362/amazon.svg";
                }
              ];
            }
          ];
        }
      ];
      services = [
        {
          Home = [
            {
              "Home Assistant" = {
                href = "http://hass.nixlap.top/";
                icon = "https://cdn.icon-icons.com/icons2/2107/PNG/512/file_type_homeassistant_icon_130543.png";
              };
            }
            {
              "Node-RED" = {
                href = "http://localpost.nyaa.nixlap.top:1880/";
                icon = "https://nodered.org/about/resources/media/node-red-icon.svg";
              };
            }
          ];
        }
        {
          Network = [
            {
              "AdGuard Home (localpost)" = {
                href = "https://adguard1.nixlap.top";
                icon = "https://st.agrd.eu/favicons/adguard/apple-touch-icon.png";
              };
            }
            {
              "AdGuard Home (localghost)" = {
                href = "https://adguard2.nixlap.top";
                icon = "https://st.agrd.eu/favicons/adguard/apple-touch-icon.png";
              };
            }
            {
              Headplane = {
                href = "https://hs.nixlap.top/admin";
                icon = "https://icons-for-free.com/iff/png/256/tailscale-1331550893565742691.png";
              };
            }
          ];
        }
        {
          Media = [
            {
              "Calibre Web" = {
                href = "https://books.nixlap.top";
                icon = "https://hosting.photobucket.com/albums/c155/davidosus/apple-touch-icon.png";
              };
            }
          ];
        }
        {
          Tools = [
            {
              Sunshine = {
                href = "https://lolcathost.nyaa.nixlap.top:47990/";
                icon = "https://raw.githubusercontent.com/LizardByte/Sunshine/nightly/src_assets/common/assets/web/public/images/logo-sunshine-45.png";
              };
            }
            {
              Vaultwarden = {
                href = "https://vault.nixlap.top/";
                icon = "https://raw.githubusercontent.com/dani-garcia/vaultwarden/main/resources/vaultwarden-icon.svg";
              };
            }
            {
              Linkding = {
                href = "https://linkding.nixlap.top/";
                icon = "https://lh3.googleusercontent.com/bp6jwFNA7tzooOc6OfnBsfy2D5SIDomN1imuF2WZqlZiJUU0cHC8ilZUSUuDQ69wb5UjkYnK6LJoBbk174uXTijO8s8=s60";
              };
            }
            {
              netdata = {
                href = "https://netdata.nixlap.top/";
                icon = "https://dev-to-uploads.s3.amazonaws.com/uploads/organization/profile_image/3293/0fc83944-0e3d-438e-bc6f-7d187e7562d7.png";
              };
            }
            {
              open-webui = {
                href = "https://ai.nixlap.top/";
                icon = "https://avatars.githubusercontent.com/u/158137808?s=200&v=4";
              };
            }
          ];
        }
      ];
      widgets = [
        {
          logo = {
            icon = "https://wiki.nixos.org/nixos.png";
          };
        }
        {resources = false;}
        {
          datetime = {
            text_size = "3x1";
            format = {
              timeStyle = "short";
              dateStyle = "short";
              hourCycle = "h23";
            };
          };
        }
        {
          search = {
            provider = "custom";
            url = "https://search.nixlap.top/search?q=";
            focus = false;
            target = "_blank";
          };
        }
        {
          openmeteo = {
            label = "Weather";
            timezone = "Asia/Tokyo";
            units = "metric";
            cache = 5; # Time in minutes to cache API responses, to stay within limits
          };
        }
      ];
      settings = {
        title = "Homepage";
        background = {
          image = "https://raw.githubusercontent.com/Gingeh/wallpapers/main/minimalistic/hearts.png";
        };
        cardBlur = "xl";
        theme = "dark";
        color = "slate";
        favicon = "https://camo.githubusercontent.com/8c73ac68e6db84a5c58eef328946ba571a92829b3baaa155b7ca5b3521388cc9/68747470733a2f2f692e696d6775722e636f6d2f367146436c41312e706e67";
        hideVersion = "true";
        headerStyle = "underlined";
      };
    };
  };
}
