{lib, ...}:
with lib; let
  folder = ./.;
  toImport = name: _value: folder + ("/" + name);
  filterCaches = key: value:
    value == "regular" && lib.hasSuffix ".nix" key && key != "default.nix";
  imports =
    lib.mapAttrsToList toImport
    (lib.filterAttrs filterCaches (builtins.readDir folder));
in {
  inherit imports;
  options = {
    modules.services.monitoring.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = {};
}
