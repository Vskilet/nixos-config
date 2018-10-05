self: super:
let
  unstable = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  jackett = unstable.jackett;
  radarr = unstable.radarr;
  sonarr = unstable.sonarr;
  roundcube = unstable.roundcube;
  nextcloud = unstable.nextcloud;
}

