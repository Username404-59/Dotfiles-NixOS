{ config, lib, ... }:

let
  sites = { # Bare hostnames only
    "mc.username404.fr" = {
      root = "https://localhost:8443";
      paths = {
        "/bluemap" = "http://localhost:8100";
        "/colonyweb" = "http://localhost:8723";
      };
    };
    # TODO Remove if moved from old server
    "www.username404.fr".root = "http://192.168.1.92";
    "gits.username404.fr" = {
      root = "http://192.168.1.92";
      difficulty = 7;
    };
    "ci.username404.fr".root = "http://192.168.1.92";
  };

  # Localhost-only port where Caddy does the routing after Anubis
  internalPort = 8081;

  instanceName = host: builtins.replaceStrings [ "." ] [ "-" ] host;

  socketPath = host:
    config.services.anubis.instances.${instanceName host}.settings.BIND;

  # skips cert verification only for https:// targets
  proxyTo = target:
    if lib.hasPrefix "https://" target then ''
      reverse_proxy ${target} {
        transport http {
          tls_insecure_skip_verify
        }
      }
    '' else ''
      reverse_proxy ${target}
    '';

  # One subpath: redirect "/x" to "/x/", then strip "/x" and forward
  pathBlock = path: target: ''
    redir ${path} ${path}/
    handle ${path}/* {
      uri strip_prefix ${path}
      ${proxyTo target}
    }
  '';

  # One host: all its subpaths, then the root as catch-all
  routing = site: ''
    bind localhost
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList pathBlock (site.paths or { }))}
    handle {
      ${proxyTo site.root}
    }
  '';
in
{
  services.anubis.defaultOptions.settings.DIFFICULTY = 4;

  # One Anubis instance per host, all forwarding to the internal router
  services.anubis.instances = lib.mapAttrs'
    (host: site:
      lib.nameValuePair (instanceName host) {
        settings = {
          TARGET = "http://localhost:${toString internalPort}";
          COOKIE_DOMAIN = host;
          DIFFICULTY = lib.mkIf (site ? difficulty) site.difficulty;
        };
      })
    sites;

  # To let Caddy read the Anubis sockets
  users.users.caddy.extraGroups = [ config.users.groups.anubis.name ];

  services.caddy = {
    enable = true;
    openFirewall = true;

    virtualHosts =
      # Public side: TLS, each host goes through its own Anubis socket
      (lib.mapAttrs (host: _site: {
        extraConfig = ''
          reverse_proxy unix/${socketPath host} {
            header_up X-Real-IP {remote_host}
          }
        '';
      }) sites)
      //
      # Internal side: plain HTTP routing after Anubis, localhost only
      (lib.mapAttrs' (host: site:
        lib.nameValuePair "http://${host}:${toString internalPort}" {
          extraConfig = routing site;
        }
      ) sites);
  };
}