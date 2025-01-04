{ pkgs, lib, config, ... }:

{
  age.secrets.vultr = {
    file = ./secrets/vultr.age;
    path = "/var/lib/acme/vultr.key";
    owner = "acme";
    group = "acme";
    mode = "600";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "them+acme@nullablevo.id.au";
    defaults.dnsProvider = "vultr";
    defaults.credentialFiles."VULTR_API_KEY_FILE" = config.age.secrets.vultr.path;
  };
}
