{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-22_05.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs@{ self, utils, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver }: utils.lib.mkFlake {

    inherit self inputs;

    supportedSystems = [ "x86_64-linux" ];

    channels.nixpkgs = {
      config.allowUnfree = true;
      overlaysBuilder = channels: [
        (final: prev: { inherit (channels.nixpkgs-unstable) unifi7; })
      ];
    };

    hostDefaults.modules = [
      nixpkgs.nixosModules.notDetected
      {
        nix.generateRegistryFromInputs = true;
        nix.linkInputs = true;
        nix.generateNixPathFromInputs = true;
      }
    ];

    hosts.SENNAS01 = {
      channelName = "nixpkgs";
      modules = [
        #"${nixpkgs-unstable}/nixos/modules/services/audio/navidrome.nix"
        simple-nixos-mailserver.nixosModule
        ./systems/SENNAS01/configuration.nix
      ];
    };
  };
}
