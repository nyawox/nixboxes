{pkgs, ...}: {
  home.packages = with pkgs; [
    pciutils
    steam-run
    vesktop
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
  # services.flatpak.packages = [
  #   "org.telegram.desktop"
  # ];
}
