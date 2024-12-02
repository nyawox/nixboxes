{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.disko;
  hostname = config.networking.hostName;
in
{
  imports = [ inputs.disko.nixosModules.disko ];
  options = {
    modules.sysconf.disko = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
    tmpfsroot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Mount tmpfs as root. disable only on devices with low ram.
        '';
      };
      size = mkOption {
        type = types.str;
        default = "2G";
        description = ''
          Set root tmpfs maximum size.
        '';
      };
    };
    disk = {
      device = mkOption {
        type = types.str;
        default = "/dev/nvme0n1";
        description = ''
          Device to install nixos
        '';
      };
      encryption = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable luks encryption
          '';
        };
        interactive = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable to use password-based interactive login
          '';
        };
        pbkdf = mkOption {
          type = types.str;
          default = "argon2id";
          description = ''
            Use old PBKDF2 for low memory device
          '';
        };
      };
    };
    esp = {
      size = mkOption {
        type = types.str;
        default = "1G";
        description = ''
          Set /boot partition size
        '';
      };
      mbr = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable mbr
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    services.fstrim.enable = mkDefault true;
    disko.devices = {
      disk.disk1 = {
        inherit (config.disk) device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = mkIf config.esp.mbr {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            esp = {
              label = "ESP";
              name = "ESP";
              size = "${config.esp.size}";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = mkIf config.disk.encryption.enable {
              size = "100%";
              label = "${hostname}_luks";
              content = {
                type = "luks";
                name = hostname;
                extraFormatArgs = [ "--pbkdf ${config.disk.encryption.pbkdf} --hash sha256" ];
                extraOpenArgs = [ "--allow-discards" ];
                askPassword = true;
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "${hostname}"
                    "-f"
                  ];
                  subvolumes = {
                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "subvol=nix"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "noatime"
                        "nosuid"
                        "nodev"
                      ];
                    };
                    "persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "subvol=persist"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "nosuid"
                        "nodev"
                      ];
                    };
                    "rootfs" = mkIf (!config.tmpfsroot.enable) {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=rootfs"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "nosuid"
                        "nodev"
                      ];
                    };
                    "root-blank" = mkIf (!config.tmpfsroot.enable) { };
                  };
                };
              };
            };
            root = mkIf (!config.disk.encryption.enable) {
              size = "100%";
              label = "${hostname}";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "${hostname}"
                  "-f"
                ];
                subvolumes = {
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress-force=zstd:1"
                      "noatime"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                  };
                  "persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress-force=zstd:1"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                  };
                  "rootfs" = mkIf (!config.tmpfsroot.enable) {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=rootfs"
                      "compress-force=zstd:1"
                      "space_cache=v2"
                      "nosuid"
                      "nodev"
                    ];
                  };
                  "root-blank" = mkIf (!config.tmpfsroot.enable) { };
                };
              };
            };
          };
        };
      };
    };
    disko.devices.nodev."/" = mkIf config.tmpfsroot.enable {
      fsType = "tmpfs";
      mountOptions = [
        "size=${config.tmpfsroot.size}"
        "defaults"
        "mode=755"
        "nosuid"
        "nodev"
      ];
    };
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persist".neededForBoot = true;
    boot = {
      supportedFilesystems = [ "btrfs" ];
      loader = {
        systemd-boot.enable = mkIf config.esp.mbr false;
        grub = mkIf config.esp.mbr {
          enable = true;
          devices = [ config.disk.device ];
          efiSupport = true;
          enableCryptodisk = mkIf config.disk.encryption.enable true;
        };
      };
      initrd.systemd.services = mkIf (!config.tmpfsroot.enable) {
        rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = [ "initrd.target" ];
          after = mkIf config.disk.encryption.enable [
            # LUKS/TPM process
            "systemd-cryptsetup@${hostname}.service"
          ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt
            # We first mount the btrfs root to /mnt
            # so we can manipulate btrfs subvolumes.
            mount -o subvol=/ ${
              if config.disk.encryption.enable then
                "/dev/mapper/" + hostname
              else
                "/dev/disk/by-label/" + hostname
            } /mnt
            # While we're tempted to just delete /root and create
            # a new snapshot from /root-blank, /root is already
            # populated at this point with a number of subvolumes,
            # which makes `btrfs subvolume delete` fail.
            # So, we remove them first.
            #
            # /root contains subvolumes:
            # - /root/var/lib/portables
            # - /root/var/lib/machines
            #
            # I suspect these are related to systemd-nspawn, but
            # since I don't use it I'm not 100% sure.
            # Anyhow, deleting these subvolumes hasn't resulted
            # in any issues so far, except for fairly
            # benign-looking errors from systemd-tmpfiles.
            btrfs subvolume list -o /mnt/rootfs |
              cut -f9 -d' ' |
              while read subvolume; do
                echo "deleting /$subvolume subvolume..."
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "deleting /root subvolume..." &&
              btrfs subvolume delete /mnt/rootfs
            echo "restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/root-blank /mnt/rootfs
            # Once we're done rolling back to a blank snapshot,
            # we can unmount /mnt and continue on the boot process.
            umount /mnt
          '';
        };
      };
    };
  };
}
