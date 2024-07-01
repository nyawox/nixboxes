# nixboxes

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![nixos-unstable](https://img.shields.io/badge/unstable-nixos?style=for-the-badge&logo=nixos&logoColor=cdd6f4&label=NixOS&labelColor=11111b&color=b4befe)](https://github.com/NixOS/nixpkgs)
[![GitHub Actions](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fnyawox%2Fnixboxes%2Fbadge%3Fref%3Dmain&style=for-the-badge&labelColor=11111b)](https://actions-badge.atrox.dev/nyawox/nixboxes/goto?ref=main)
[![LICENSE](https://img.shields.io/github/license/nyawox/nixboxes.svg?style=for-the-badge&labelColor=11111b&color=94e2d5)](https://github.com/nyawox/nixboxes)

![](./assets/screenshot.png) _(Note: the screenshot is outdated, currently running niri.)_

## Quick Start

**SSH keys in /etc/ssh will be copied over to the new installation.**

### bin/localinstall

```bash
Usage: localinstall -h <hostname> [options]

Options:

 -h, --host <hostname>
   Set the config hostname to install from this flake.

 --secureboot
   Generate secure boot keys.

 --initrdssh
   Generate initrd SSH host keys.
```

### bin/remoteinstall

```bash
Usage: remoteinstall -h <hostname> -p <port> -i <ip> [options]

Options:

 -h, --host <hostname>
   Set the config hostname to install from this flake.

 -p, --port <ssh_port>
   Set the SSH port to connect with.

 -i, --ip <ssh_ip>
   Set the destination IP to install.

 --secureboot
   Generate secure boot keys.

 --initrdssh
   Generate initrd SSH host keys.
```

`--initrdssh` requires sudo.

## Deploy

`deploy -k` deploys all hosts and keeps garbage collection roots in `.deploy-gc`.

Pass `-s` to skip flake checks.
