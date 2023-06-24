{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    imv
    prismlauncher
    genymotion
    pciutils
    steam-run
    steam
    dmidecode
    lutris
    inputs.latest.legacyPackages.${system}.heroic
    wineWowPackages.waylandFull
    vesktop
    (pkgs.makeDesktopItem {
      name = "vencorddesktop-wayland";
      exec = "${pkgs.vesktop}/bin/vencorddesktop -enable-features=UseOzonePlatform --ozone-platform=wayland %U";
      desktopName = "Vesktop Wayland";
      icon = "vencorddesktop";
      startupWMClass = "VencordDesktop";
      genericName = "Internet Messenger";
      keywords = ["discord" "vencord" "electron" "chat"];
    })
    webcord-vencord
    tdesktop
    samba
    unzip
    unrar
    unar
    mangohud
    nvme-cli
    smartmontools
    imagemagick
    fd
    transmission-remote-gtk
    ffmpegthumbnailer
    mediainfo
    weston
    cabextract
    appimage-run
    screen
    killall
    libimobiledevice
    ifuse
    google-chrome
    cemu
    efibootmgr
    gimp
    pavucontrol
    rpcs3
    ryujinx
    btrfs-progs
    progress
    parted
    glxinfo
    citra-nightly
    gamescope
    nix-prefetch-github
    nix-prefetch-git
    cava
    bc
    ripgrep
    uget
    aria2
    ventoy
    e2fsprogs
    xarchiver
    p7zip
    breeze-icons
    gnome.nautilus
    openjdk
    mpv
    gradience
    iwgtk
  ];
}
