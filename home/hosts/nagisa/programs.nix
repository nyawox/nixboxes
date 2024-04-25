{pkgs, ...}: {
  home.packages = with pkgs; [
    pciutils
    steam-run
    vesktop
    webcord-vencord
    tdesktop
    mangohud
    gimp
    pavucontrol
    btrfs-progs
    parted
    glxinfo
    gamescope
    nix-prefetch-github
    nix-prefetch-git
    cava
    gnome.nautilus
  ];
}
