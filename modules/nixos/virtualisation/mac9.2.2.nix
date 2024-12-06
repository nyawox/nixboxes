# MacOS Classic
# the "acquired" iso should be 578.9 MiB (607MB)
{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.virtualisation.mac922;
  virtLib = inputs.nixvirt.lib;
in
{
  options = {
    modules.virtualisation.mac922 = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    modules.virtualisation.libvirtd.enable = mkForce true;
    # without "d". nixvirt module
    virtualisation.libvirt.connections."qemu:///system" = {
      pools = [
        {
          active = true;
          definition = virtLib.pool.writeXML {
            name = "mac922";
            uuid = "c189cc4a-ef70-4aff-9ad2-dfd326151602";
            type = "dir";
            target = {
              path = "/home/${username}/vmstore/mac922";
            };
          };
          volumes = [
            {
              definition = virtLib.volume.writeXML {
                name = "mac922.qcow2";
                capacity = {
                  count = 2;
                  unit = "GiB";
                };
                target = {
                  format = {
                    type = "qcow2";
                  };
                };
              };
            }
          ];
        }
      ];
      domains = [
        {
          definition =
            let
              storageFile = "/home/${username}/vmstore/mac922/mac922.qcow2";
              isoFile = "/home/${username}/vmstore/mac922/mac922.iso";
            in
            virtLib.domain.writeXML {
              type = "qemu";
              name = "mac9.2.2";
              uuid = "e3d38bb4-0b99-4aef-98ce-d97afee2b16d";
              memory = {
                count = 512;
                unit = "MiB";
              };
              vcpu = {
                placement = "static";
                count = 1;
              };
              os = {
                type = "hvm";
                arch = "ppc";
                machine = "mac99";
              };
              clock.offset = "utc";
              on_poweroff = "destroy";
              on_reboot = "restart";
              on_crash = "destroy";
              devices = {
                emulator = "${pkgs.nur.repos.Rhys-T.qemu-screamer}/bin/qemu-system-ppc"; # screamer build with audio support
                controller = [
                  {
                    type = "usb";
                    index = 0;
                    model = "piix3-uhci";
                    address = {
                      type = "pci";
                      domain = 0;
                      bus = 0;
                      slot = 2;
                      function = 0;
                    };
                  }
                  {
                    type = "pci";
                    index = 0;
                    model = "pci-root";
                  }
                ];
                graphics = {
                  type = "spice";
                  listen = {
                    type = "none";
                  };
                  image = {
                    compression = false;
                  };
                  gl = {
                    enable = false;
                  };
                };
                video = {
                  model = {
                    type = "none";
                  };
                };
                memballoon = {
                  model = "none";
                };
              };
              qemu-commandline = {
                arg = [
                  { value = "-M"; }
                  { value = "mac99,usb=on"; } # won't boot without `usb=on`. libvirt don't allow removing usb controller
                  { value = "-device"; }
                  { value = "ide-hd,bus=ide.0,drive=Macintosh"; }
                  { value = "-drive"; }
                  {
                    value = "if=none,format=qcow2,media=disk,id=Macintosh,file=${storageFile},discard=unmap,detect-zeroes=unmap";
                  }
                  { value = "-device"; }
                  { value = "ide-cd,bus=ide.0,drive=Installer"; }
                  { value = "-drive"; }
                  {
                    value = "if=none,format=raw,media=cdrom,id=Installer,file=${isoFile},discard=unmap,detect-zeroes=unmap";
                  }
                  { value = "-device"; }
                  { value = "sungem,mac=2A:84:84:06:3E:78,netdev=net0"; }
                  { value = "-netdev"; }
                  { value = "user,id=net0"; }
                  { value = "-device"; }
                  { value = "VGA,edid=on"; }
                  { value = "-prom-env"; }
                  { value = "boot-args=-v"; }
                  { value = "-prom-env"; }
                  { value = "vga-ndrv?=true"; }
                  { value = "-prom-env"; }
                  { value = "auto-boot?=true"; }
                  { value = "-g"; }
                  { value = "1024x768x32"; }
                  { value = "-boot"; }
                  { value = "c"; } # set to d when booting from iso
                ];
              };
            };
        }
      ];
    };
    environment.persistence."/persist".users."${username}".directories =
      mkIf config.modules.sysconf.impermanence.enable
        [
          "vmstore/mac922"
        ];
  };
}
