# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <agenix/modules/age.nix>
      ./database.nix
      ./acme.nix
      ./matrix.nix
      ./www.nix
      ./proxy.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking = {
    hostName = "obelisk";
    domain = "nullablevo.id.au";
  };

  time.timeZone = "Australia/Sydney";

  users = {
    groups.www-data = {};

    users.avery = {
      isNormalUser = true;
      extraGroups = [ "wheel" "www-data" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
      initialPassword = "changeme";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLS+zE1eW9LARG9iIliGGHbJmuY1ulGVOp9dvEfTKyb void@catboy-hackermaid"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    (pkgs.callPackage <agenix/pkgs/agenix.nix> {})
  ];

  services.openssh.enable = true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.copySystemConfiguration = true;

  system.stateVersion = "24.11";

}

