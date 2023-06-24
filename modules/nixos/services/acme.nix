{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services.acme;
in {
  options = {
    modules.services.acme = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "93813719+nyawox@users.noreply.github.com";

      certs."nixhome.shop" = {
        domain = "nixhome.shop";
        extraDomainNames = ["*.nixhome.shop"];
        dnsProvider = "vultr";
        dnsPropagationCheck = true;
        credentialsFile = config.sops.secrets.vultr.path;
      };
    };
    sops.secrets.vultr = {
      sopsFile = ../../../secrets/vultr.env;
      format = "dotenv";
    };

    users.users.caddy.extraGroups = ["acme"];
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable ["/var/lib/acme"];
  };
}
