{ pkgs, lib, config, ... }:

{
  security.acme.certs = {
    "nullablevo.id.au" = {
      extraDomainNames = [
        "www.nullablevo.id.au"
        "openpgpkey.nullablevo.id.au"
      ];
    };
  };

  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    group = "www-data";

    defaultListen = [{
      addr = "[::1]";
      port = 8080;
      ssl = false;
    }];

    virtualHosts."nullablevo.id.au" = {
      root = /srv/www/nullablevo.id.au;

      locations."/.well-known/".extraConfig = ''
        add_header Access-Control-Allow-Origin * always;
        access_log off;
      '';

      locations."/.well-known/discord".extraConfig = ''
        return 200 'dh=fe501c89e86d8120dde5b2a76863d509edd7501d';
      '';

      locations."~ ^/.well-known/openpgpkey/.*/hu/".extraConfig = ''
        default_type "application/octet-stream";
      '';
    };
  };
}
