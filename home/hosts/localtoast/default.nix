{ lib, ... }:
let
  folder = ./.;
  toImport = name: _value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key && key != "default.nix";
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in
{
  inherit imports;
  modules.desktop.vivaldi.enable = true;
}
