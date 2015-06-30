{ config, pkgs, ...}:

let
  blog = pkgs.haskell.packages.ghc7101.callPackage ./default.nix {};
in

{
  systemd.services.blog = {
    description = "eric's blog";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    #path = [ blog ];
    environment = { PORT = "9000"; };
    serviceConfig = {
      WorkingDirectory = ./.;
      ExecStart = "${blog}/bin/blog";
    };
  };

  services.nginx.httpConfig = ''
    server {
      listen 80;
      server_name eseidel.org;
      return 301 $scheme://eric.seidel.io$request_uri;
    }
    server {
      listen 80;
      server_name www.eseidel.org;
      return 301 $scheme://eric.seidel.io$request_uri;
    }
    server {
      listen 80;
      server_name eric.seidel.io;
      location / {
        proxy_pass http://127.0.0.1:9000;
      }
    }
    server {
      listen 80;
      server_name seidel.io;
      location /liquidhaskell/ {
        rewrite /liquidhaskell/(.*) /$1 break;
        proxy_pass http://127.0.0.1:8090;
      }
    }
  '';
}
