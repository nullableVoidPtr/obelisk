{ pkgs, lib, config, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 8448 ];

  security.acme.certs = {
    "nullablevo.id.au" = {
      group = config.services.haproxy.group;
    };
  };

  services.haproxy = {
    enable = true;
    config = ''
      frontend entrypoint
        mode http
        option httplog

        bind :80
        bind :::443 v4v6 ssl crt /var/lib/acme/nullablevo.id.au/full.pem strict-sni alpn h2,http/1.1

        acl http     ssl_fc,not
        acl host_www hdr_beg(host) www.
        http-request redirect prefix https://nullablevo.id.au if http or host_www

        http-request set-header X-Forwarded-Proto https if { ssl_fc }
        http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
        http-request set-header X-Forwarded-For %[src]

        # Matrix client traffic
        acl matrix-host hdr(host) -i matrix.nullablevo.id.au
        acl matrix-path path_beg /_matrix
        acl matrix-path path_beg /_synapse/client

        use_backend matrix if matrix-host OR matrix-path

        default_backend nginx

      frontend matrix-federation
        mode http
        option httplog

        bind :::8448 v4v6 ssl crt /var/lib/acme/nullablevo.id.au/full.pem alpn h2,http/1.1
        http-request set-header X-Forwarded-Proto https if { ssl_fc }
        http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
        http-request set-header X-Forwarded-For %[src]

        default_backend matrix

      backend matrix
        mode http
        server matrix [::1]:8008

      backend nginx
        mode http
        server nginx [::1]:8080
    '';
  };
}
