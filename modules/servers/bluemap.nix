{ ... }:

let
  targeted_crafty_server_id = "aeacaf83-7dc5-4e16-8448-f659748b835c";
  used_compress_format = "zstd"; # has to be the one configured in config/bluemap/storages/file.conf
in
{
  services.caddy.virtualHosts."http://:8201".extraConfig = ''
    bind localhost
    root * /var/lib/crafty/servers/${targeted_crafty_server_id}/bluemap/web/

    # Catch the error and serve "live" data from the disk when the integrated webserver can't be reached
    handle_errors {
      try_files {path} =204
        file_server {
          status 200
        }
      }

    @${used_compress_format} path /maps/*/textures.json *.prbm
    handle @${used_compress_format} {
      try_files {path}.${used_compress_format} =204
        header Content-Encoding ${used_compress_format}
      }

    # Respond with 204 for non-existant map-tiles
    @204 path */tiles/*
    handle @204 {
      try_files {path} =204
    }

    # Proxy requests for live data to the bluemaps integrated webserver.
    # Trigger an error and fall back to our local files if the server can't be reached.
    @live path /maps/*/live/*
    handle @live {
      reverse_proxy http://localhost:8100 {
        transport http {
          response_header_timeout 3s
        }
      }
    }

    file_server
  '';
}