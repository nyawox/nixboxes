{pkgs, ...}: {
  home.packages = with pkgs; [
    pciutils
    steam-run
    gimp
    pavucontrol
    btrfs-progs
    parted
    glxinfo
    nix-prefetch-github
    nix-prefetch-git
    cava
    nautilus
    trayscale
    vesktop
  ];
  # services.flatpak.packages = [
  #   "org.telegram.desktop"
  # ];
}
