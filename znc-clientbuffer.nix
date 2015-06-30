{ stdenv, fetchurl, fetchFromGitHub,  znc }:

let

  zncDerivation = a@{
    name, src, module_name,
    buildPhase ? "${znc}/bin/znc-buildmod ${module_name}.cpp",
    installPhase ? "install -D ${module_name}.so $out/lib/znc/${module_name}.so", ...
  } : stdenv.mkDerivation (a // {
    inherit buildPhase;
    inherit installPhase;

    meta = { platforms = stdenv.lib.platforms.unix; };
    passthru.module_name = module_name;
  });

in

zncDerivation rec {
  name = "znc-clientbuffer-${version}";
  version = "1.6.0";
  module_name = "clientbuffer";

  src = fetchFromGitHub {
    owner = "jpnurmi";
    repo = "znc-clientbuffer";
    rev = "znc-1.6.0";
    sha256 = "1zmlnh7pfxx3s6l7w47l7myppn3qv7rv9miyja45nqsbccivmjyc";
  };
}
