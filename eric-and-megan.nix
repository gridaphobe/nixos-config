{ config, pkgs, ...}:

{
  #systemd.services.eric-and-megan = {
  #  description = "eric and megan's wedding site";
  #  after = [ "network.target" ];
  #  wantedBy = [ "multi-user.target" ];
  #  path = [ pkgs.haskellngPackages.hakyll ];
  #  serviceConfig = {
  #    WorkingDirectory = ./.;
  #    ExecStart = "hakyll build";
  #  };
  #};

  services.nginx.httpConfig = ''
    server {
      listen 80;
      server_name eric-and-megan.seidel.io;
      location / {
        root ${./_site};
      }
    }
  '';
}
