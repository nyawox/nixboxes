{pkgs, ...}: {
  home.packages = with pkgs; [
    pciutils
    steam-run
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
    mangohud
    gimp
    pavucontrol
    btrfs-progs
    parted
    glxinfo
    citra-nightly
    gamescope
    nix-prefetch-github
    nix-prefetch-git
    cava
    gnome.nautilus
    mpv
  ];
}
