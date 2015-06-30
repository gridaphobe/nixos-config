# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let head-packages = import /home/gridaphobe/Source/nixpkgs {}; in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./blog.nix
      ./eric-and-megan.nix
    ];

  # Use the GRUB 1 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 1;
    extraPerEntryConfig = "root (hd0)";
    device = "nodev";
    configurationLimit = 10;
  };

  boot.kernelParams = [ "console=ttyS0" "root=/dev/sdc" ];

  networking.hostName = "hermes"; # Define your hostname.
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 80 5000 8090 40900 ];
  # networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search by name, run:
  # -env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bashInteractive
    curl
    emacs
    gitAndTools.gitFull
    screen
    tmux
    vim
    weechat
    wget
    znc

    #head-packages.haskell.packages.ghc784.liquid-fixpoint
    #head-packages.haskell.packages.ghc784.liquidhaskell
    #z3
  ];

  # Live on the edge
  # nix.package = pkgs.nixUnstable;

  nixpkgs.config.allowUnfree = true;

  # Clean up after yourself..
  nix.gc.automatic = true;
  nix.gc.dates = "03:14";
  nix.gc.options = "--delete-older-than 30d";
  nix.extraOptions = ''
    gc-keep-output = true
    gc-keep-derivations = true
    auto-optimise-store = true
    binary-caches = https://cache.nixos.org https://hydra.nixos.org http://hydra.cryp.to
    trusted-binary-caches = https://cache.nixos.org https://hydra.nixos.org http://hydra.cryp.to
  '';

  programs.bash.enableCompletion = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.znc = {
    enable = true;
    zncConf = pkgs.lib.readFile ./znc.conf;
    #user = "gridaphobe";
    #dataDir = "/home/gridaphobe/.znc/";
    #mutable = true;
    modulePackages = [ (pkgs.callPackage ./znc-clientbuffer.nix {}) ]; 
  };

  services.nginx.enable = true;
  services.nginx.config = ''
    worker_processes  1;
    
    error_log  logs/error.log;
    
    pid        logs/nginx.pid;
    
    events {
        worker_connections  1024;
    }
  '';
  services.nginx.httpConfig = ''
    include       ${./mime.types};
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  logs/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    gzip  on;
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.gridaphobe = {
    isNormalUser = true;
    description = "Eric Seidel";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$etRyiK1.PKY7$yMxQF1Qn85/GyYoh5MGStqv9Ov7tXEykuu3k8N/rqBGtuOdx6eAn6VazlIuYg2lVi6l1VUobBwIGvo14h07Tl.";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSRyCpnAAgbajz2lPBBRVSNtYqvVdf0tADBUpZFi7JeGO4pOc3iLVK3QmkawFm53Tv/fMgDvBm+0fCYRggSdJcqpTToLQiSNo+KmQ7Rcqj8+MAS03gY9RaVvfX8yQ9VCJGsqikH3pqLPEfdcHte8G8+nYFZAb8TmrxYxSm3Pa0ZNmmUU0Zj6lqjgAkXmmtZPkVZKWH0z9oQ+sGKZedjJullsFVHLCVeN7fY0vBHKZVoVmgblduGzELBIoN1p3iGq1QiQze9vMJHhvcZQI0M5aKNY6sai5vddx3xIUpSeXWC2uipsbIilR4ranmi1uW0/LqsE87VxMKeNZsveBKHDif gridaphobe@mimir" ];
  };
  users.mutableUsers = false;

}
