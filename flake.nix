{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-23_05.follows = "nixpkgs";
      };
    };
    nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
  };

  outputs = inputs@{ self, utils, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver, nix-matrix-appservices }: utils.lib.mkFlake {

    inherit self inputs;

    supportedSystems = [ "x86_64-linux" ];

    channels = {
      nixpkgs = {
        patches = [
          (nixpkgs.legacyPackages."x86_64-linux".fetchpatch {
            name = "unifi-7.4.156";
            url = "https://github.com/NixOS/nixpkgs/commit/756f6cc1ef2da00e1e60ee86286fe6b22f6a5949.patch";
            sha256 = "sha256-vCmIxWzt7AeC0rdjS90GxsvFEGQ5A7pMj+wKpNhTcQM=";
          })
          (nixpkgs.legacyPackages."x86_64-linux".fetchpatch {
            name = "mautrix-0.19.16";
            url = "https://github.com/NixOS/nixpkgs/commit/f449215e3850172ae90ae9783051a5a781cb3c87.patch";
            sha256 = "sha256-VQz4z3bCTb4AiQGCM9bb2hLNclyjEjfjjHrn+FqSn6M=";
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
