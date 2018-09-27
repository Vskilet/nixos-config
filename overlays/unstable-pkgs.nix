self: super:
let
  unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {};
in
{
  jackett = unstable.jackett;
  radarr = unstable.radarr;
  sonarr = unstable.sonarr;
}

