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
      defaults = {
        email = "nyawox.git@gmail.com";
        server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      };

      certs."nixlap.top" = {
        domain = "nixlap.top";
        extraDomainNames = ["*.nixlap.top"];
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.cloudflare.path;
      };
    };
    sops.secrets.cloudflare = {
      sopsFile = ../../../secrets/cloudflare.env;
      format = "dotenv";
    };

    users.users.caddy.extraGroups = ["acme"];
    users.users.headscale.extraGroups = ["acme" "caddy"]; # for some reason /var/lib/acme/<my-domain> is being assigned to the group caddy
    environment.persistence."/persist".directories = mkIf config.modules.sysconf.impermanence.enable [
      "/var/lib/acme"
    ];
  };
}
