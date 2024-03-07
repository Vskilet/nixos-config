{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-23_11.follows = "nixpkgs";
      };
    };
    nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
  };

  outputs = inputs@{ self, utils, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver, nix-matrix-appservices }: utils.lib.mkFlake {

    inherit self inputs;

    supportedSystems = [ "x86_64-linux" ];

    channels = {
      nixpkgs = {
        overlaysBuilder = channels: [
          (final: prev: { inherit (channels.nixpkgs-unstable) unifi8; })
        ];
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "unifi-controller" "unifi" "mongodb"
          ];
        };
      };
      nixpkgs-unstable = {
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "anydesk" "corefonts" "displaylink" "samsung-unified-linux-driver" "spotify" "spotify-unwrapped" "unifi-controller" "zoom"
          ];
        };
      };
    };

    hostDefaults.modules = [
      nixpkgs.nixosModules.notDetected
      {
        #nix.generateRegistryFromInputs = true;
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
