{pkgs, ...}: {
  home.packages = with pkgs; [
    unzip
    unar
    killall
    efibootmgr
    btrfs-progs
    parted
    glxinfo
    cava
    bc
    ripgrep
    uget
    aria2
    e2fsprogs
  ];
}
