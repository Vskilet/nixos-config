{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-22_11.follows = "nixpkgs";
      };
    };
    nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
  };

  outputs = inputs@{ self, utils, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver, nix-matrix-appservices }: utils.lib.mkFlake {

    inherit self inputs;

    supportedSystems = [ "x86_64-linux" ];

    channels = {
      nixpkgs = {
#        overlaysBuilder = channels: [
#          (final: prev: { inherit (channels.nixpkgs-unstable) unifi7; })
#        ];
        patches = [
          (nixpkgs.legacyPackages."x86_64-linux".fetchpatch {
            name = "unifi72.patch";
            url = "https://github.com/NixOS/nixpkgs/commit/2d8cbb5a215d2b854280be74e2d18f669751668c.patch";
            sha256 = "sha256-H0w2uEMxSHnJoQST8+gmLsl9CW+619NJ+/VJTNbcc6g=";
          })
          (nixpkgs.legacyPackages."x86_64-linux".fetchpatch {
            name = "unifi73.patch";
            url = "https://github.com/NixOS/nixpkgs/commit/8df1d1aef04d591707211eadf6e6d6cf1fdab280.patch";
            sha256 = "sha256-HuYnoMQ3GzbioQUZ/Gc6GusSp6gYDfzQg8ZAMMRrnAc=";
          })
        ];
      };
    };

    hostDefaults.modules = [
      nixpkgs.nixosModules.notDetected
      {
        nix.generateRegistryFromInputs = true;
        nix.linkInputs = true;
        nix.generateNixPathFromInputs = true;
      }
    ];

    hosts = {
      SENNAS01 = {
        channelName = "nixpkgs";
        modules = [
          simple-nixos-mailserver.nixosModule
          nix-matrix-appservices.nixosModule
          ./systems/SENNAS01/configuration.nix
        ];
      };
      SENLPT-VIC01 = {
        channelName = "nixpkgs-unstable";
        modules = [
          ./systems/SENLPT-VIC01/configuration.nix
        ];
      };
    };
  };
}
