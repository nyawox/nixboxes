{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.sysconf.tpm2;
in
{
  options = {
    modules.sysconf.tpm2 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable hardware tpm2
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true; # /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI envvar
    };
  };
}
