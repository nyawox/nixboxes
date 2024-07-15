{pkgs, ...}: {
  home.packages = with pkgs; [
    pciutils
    steam-run
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
    nautilus
    trayscale
  ];
  # services.flatpak.packages = [
  #   "org.telegram.desktop"
  # ];
}
