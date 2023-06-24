{ lib, ... }:
with lib;
{
  options.var.username = mkOption {
    default = null;
    type = types.nullOr types.str;
  };
}
