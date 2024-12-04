{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.services.firejail;
  common-args = ''
    # fix fcitx5
    dbus-user filter
    dbus-user.talk org.freedesktop.portal.Fcitx
    ignore dbus-user none
  '';
  # requires DE=flatpak env var
  fixURI = ''
    # fix opening link
    private-bin gdbus
    dbus-user.talk org.freedesktop.portal.Desktop
  '';
  # i don't want ugly font rendering and ugly non-apple emoji
  # even if it's privacy tradeoff
  fonts = ''
    noblacklist /etc/fonts
    whitelist /etc/fonts
    noblacklist ''${HOME}/.local/share/fonts
    whitelist ''${HOME}/.local/share/fonts
    noblacklist ''${HOME}/.config/fontconfig
    whitelist ''${HOME}/.config/fontconfig
  '';
in
{
  options = {
    modules.services.firejail = {
      enable = mkEnableOption "firejail";
      tor-browser = mkEnableOption "tor-browser";
      signal-desktop = mkEnableOption "signal-desktop";
      obsidian = mkEnableOption "obsidian";
      vesktop = mkEnableOption "vesktop";
      vivaldi = mkEnableOption "vivaldi";
      netflix = mkEnableOption "netflix";
      uget = mkEnableOption "uget";
    };
  };
  config = mkMerge [

    (mkIf cfg.enable {
      programs.firejail.enable = true;

      environment.systemPackages = [
        (
          let
            packageNames = [
              "tor-browser"
              "signal-desktop"
              "obsidian"
              "vesktop"
              "vivaldi"
              "uget"
            ];
            packages = builtins.filter (pkg: pkg != null) (
              map (name: if builtins.getAttr name cfg then builtins.getAttr name pkgs else null) packageNames
            );
          in
          pkgs.runCommand "firejail-icons"
            {
              preferLocalBuild = true;
              allowSubstitutes = false;
              meta.priority = -1;
            }
            ''
              mkdir -p "$out/share/icons"
              ${concatStringsSep "\n" (
                map (pkg: ''
                  tar -C "${pkg}" -c share/icons -h --mode=0755 -f - | tar -C "$out" -xf -
                '') packages
              )}
              find "$out/" -type f -print0 | xargs -0 chmod 0444
              find "$out/" -type d -print0 | xargs -0 chmod 0555
            ''
        )
      ];

    })
    (mkIf cfg.tor-browser {
      programs.firejail.wrappedBinaries.tor-browser = {
        executable = "${getExe pkgs.tor-browser}";
        desktop = "${pkgs.tor-browser}/share/applications/torbrowser.desktop";
        profile = pkgs.writeText "tor-browser.local" ''
          ${common-args}
          include tor-browser.profile
        '';
      };
    })
    (mkIf cfg.signal-desktop {
      programs.firejail.wrappedBinaries.signal-desktop =
        let
          signal-desktop = pkgs.signal-desktop.overrideAttrs (_old: {
            # https://github.com/signalapp/Signal-Desktop/pull/7078 launches minimized in wayland
            # patch show:false between `async function createWindows` and `autoHideMenuBar`
            preInstall = ''
              sed -i '/async function createWindow/,/autoHideMenuBar:/s/show: false/show: true/' asar-contents/app/main.js
            '';
            postFixup = ''
              substituteInPlace $out/bin/signal-desktop \
              --replace '--enable-wayland-ime' '--enable-wayland-ime --wayland-text-input-version=3'
              wrapProgram $out/bin/signal-desktop \
              --set DE flatpak
            '';
          });
        in
        {
          executable = "${getExe signal-desktop}";
          desktop = "${pkgs.signal-desktop}/share/applications/signal-desktop.desktop";
          profile = pkgs.writeText "signal-desktop.local" ''
            ${common-args}
            ${fixURI}
            ${fonts}
            include signal-desktop.profile
          '';
        };
      environment.persistence."/persist".users."${username}" =
        mkIf config.modules.sysconf.impermanence.enable
          {
            directories = [
              ".config/Signal"
            ];
          };
    })
    (mkIf cfg.obsidian {
      environment.systemPackages = [
        # keep unsandboxed until i fix git authentication
        # no matter what i do can't get libsecret and gnome keyring to work
        (pkgs.obsidian.overrideAttrs (_old: {
          postFixup = ''
            substituteInPlace $out/bin/obsidian \
            --replace '--enable-wayland-ime' '--enable-wayland-ime --wayland-text-input-version=3'
            wrapProgram $out/bin/obsidian \
            --set DE flatpak
          '';
        }))
      ];
      # programs.firejail.wrappedBinaries.obsidian =
      #   let
      #     obsidian = pkgs.obsidian.overrideAttrs (_old: {
      #       postFixup = ''
      #         substituteInPlace $out/bin/obsidian \
      #         --replace '--enable-wayland-ime' '--enable-wayland-ime --wayland-text-input-version=3'
      #         wrapProgram $out/bin/obsidian \
      #         --set DE flatpak
      #       '';
      #     });
      #   in
      #   {
      #     executable = "${getExe obsidian}";
      #     desktop = "${pkgs.obsidian}/share/applications/obsidian.desktop";
      #     profile = pkgs.writeText "obsidian.local" ''
      #       ${common-args}
      #       ${fixURI}
      #       ${fonts}
      #       noblacklist ''${DOCUMENTS}
      #       whitelist ''${DOCUMENTS}
      #       noblacklist ''${PICTURES}
      #       whitelist ''${PICTURES}
      #       noblacklist ''${HOME}/.config/obsidian
      #       whitelist ''${HOME}/.config/obsidian
      #       # git with ssh (and keyring) access
      #       noblacklist ''${HOME}/.config/git
      #       whitelist ''${HOME}/.config/git
      #       noblacklist ''${HOME}/.ssh/known_hosts
      #       whitelist ''${HOME}/.ssh/known_hosts
      #       noblacklist ''${HOME}/.ssh/id_ed*
      #       whitelist ''${HOME}/.ssh/id_ed*
      #       noblacklist ''${HOME}/.gnupg
      #       whitelist ''${HOME}/.gnupg
      #       noblacklist ''${RUNUSER}/gnupg/S.gpg-agent.ssh
      #       whitelist ''${RUNUSER}/gnupg/S.gpg-agent.ssh
      #       noblacklist ''${HOME}/.local/share/keyrings
      #       whitelist ''${HOME}/.local/share/keyrings
      #       dbus-user.talk org.freedesktop.secrets
      #       dbus-user.talk org.gnome.keyring.*
      #       noblacklist /tmp/ssh-*
      #       whitelist /tmp/ssh-*

      #       noblacklist ''${PATH}/nc
      #       noblacklist ''${PATH}/ncat
      #       include allow-ssh.inc
      #       whitelist ''${RUNUSER}/gcr/ssh
      #       whitelist ''${RUNUSER}/gnupg/*/S.gpg-agent.ssh # custom gpg homedir setup
      #       whitelist ''${RUNUSER}/gnupg/S.gpg-agent.ssh # default gpg homedir setup
      #       whitelist ''${RUNUSER}/gvfsd-sftp
      #       whitelist ''${RUNUSER}/keyring/ssh
      #       include whitelist-runuser-common.inc
      #       include whitelist-usr-share-common.inc

      #       ipc-namespace
      #       nonewprivs
      #       noroot
      #       protocol unix,inet,inet6,netlink

      #       private-bin basename,bash,cat,cut,electron,electron[0-9],electron[0-9][0-9],gawk,grep,obsidian,realpath,tr,git,ssh,gpg-agent,ssh-agent,gnome-keyrin*
      #       private-etc @network,@tls-ca,@x11,gnutls,libva.conf,ssh,ssl

      #       include electron-common.profile
      #     '';
      #   };
      environment.persistence."/persist".users."${username}" =
        mkIf config.modules.sysconf.impermanence.enable
          {
            directories = [
              ".config/obsidian"
            ];
          };
    })
    (mkIf cfg.vesktop {
      programs.firejail.wrappedBinaries.vesktop =
        let
          vesktop = pkgs.vesktop.overrideAttrs (old: {
            postFixup = ''
              ${old.postFixup or ""}
              substituteInPlace $out/bin/vesktop \
              --replace '--enable-wayland-ime' '--enable-wayland-ime --wayland-text-input-version=3'
              wrapProgram $out/bin/vesktop \
              --set DE flatpak
            '';
          });
        in
        {
          executable = "${getExe vesktop}";
          desktop = "${pkgs.vesktop}/share/applications/vesktop.desktop";
          profile = pkgs.writeText "discord.local" ''
            ${common-args}
            ${fixURI}
            ${fonts}
            # whitelist vesktop config folder
            mkdir ''${HOME}/.config/vesktop
            whitelist ''${HOME}/.config/vesktop
            include discord.profile
          '';
        };
      environment.persistence."/persist".users."${username}" =
        mkIf config.modules.sysconf.impermanence.enable
          {
            directories = [
              ".config/vesktop"
            ];
          };
    })
    (mkIf cfg.vivaldi {
      programs.firejail.wrappedBinaries.vivaldi =
        let
          vivaldi = pkgs.vivaldi.override {
            proprietaryCodecs = true;
            enableWidevine = true; # Wide*V*ine for chromium, Wide*v*ine for vivaldi
            commandLineArgs = "--wayland-text-input-version=3 --force-dark-mode";
          };
        in
        {
          executable = "${getExe vivaldi}";
          desktop = "${vivaldi}/share/applications/vivaldi-stable.desktop";
          profile = pkgs.writeText "vivaldi-stable.local" ''
            ${common-args}
            include vivaldi-stable.profile
          '';
        };
      environment = {
        persistence."/persist".users."${username}" =
          mkIf (config.modules.sysconf.impermanence.enable && cfg.vivaldi)
            {
              directories = [
                ".config/vivaldi"
              ];
            };
        # netflix 1080p and darkreader
        etc."chromium/policies/managed/netflix.json".text = ''
          {
            "ExtensionInstallForcelist": ["mdlbikciddolbenfkgggdegphnhmnfcg", "eimadpbcbfnmbkopoojfekhnkhdbieeh"], 
            "ExtensionManifestV2Availability": 2
          }
        '';
      };
    })
    (mkIf cfg.netflix {
      modules.services.firejail.vivaldi = mkForce true;
      environment.systemPackages =
        let
          icon = pkgs.fetchurl {
            name = "netflix-icon-2016.png";
            url = "https://assets.nflxext.com/us/ffe/siteui/common/icons/nficon2016.png";
            sha256 = "sha256-c0H3uLCuPA2krqVZ78MfC1PZ253SkWZP3PfWGP2V7Yo=";
          };
        in
        [
          (pkgs.makeDesktopItem {
            name = "Netflix";
            desktopName = "Netflix";
            inherit icon;
            exec = "vivaldi --app=https://www.netflix.com --no-first-run --no-default-browser-check --no-crash-upload";
          })
        ];
    })
    (mkIf cfg.uget {
      programs.firejail.wrappedBinaries.uget = {
        executable = "${getExe pkgs.uget}";
        desktop = "${pkgs.uget}/share/applications/uget-gtk.desktop";
        profile = pkgs.writeText "uget-gtk.local" ''
          ${common-args}
          ${fonts}
          include uget-gtk.profile
        '';
      };
      environment.persistence."/persist".users."${username}" =
        mkIf config.modules.sysconf.impermanence.enable
          {
            directories = [
              ".config/uGet"
            ];
          };
    })
  ];
}
