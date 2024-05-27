{ pkgs, ... }:
{
  home.packages = with pkgs; [
    helix
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
