#with (import <nixpkgs> {});
{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name= "roundcube-${version}";
  version = "1.3.6";

  src = fetchurl {
    url = "https://github.com/roundcube/roundcubemail/releases/download/1.3.6/roundcubemail-1.3.6-complete.tar.gz"; 
    sha256 = "f1b86e97cc8fd69bb1957d4115762af6ea2d6957ea17b33dd3ec2995662670d9"; 
  };

  installPhase = ''
    mkdir -p $out/
    cp -R . $out/
  '';

  meta = {
    description = "Instance de Roundcube";
    homepage = https://webmail.sene.ovh/;
    maintainers = with stdenv.lib.maintainers; [ vskilet ];
    license = stdenv.lib.licenses.cc-by-nc-sa-40;
    platforms = stdenv.lib.platforms.all;
  };
}


