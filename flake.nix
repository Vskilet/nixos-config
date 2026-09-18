{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-26_05.follows = "nixpkgs";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-26_05.follows = "nixpkgs";
      };
    };
    nixpkgs-gmessages-pr.url = "github:SchweGELBin/nixpkgs/mautrix-gmessages-26.09";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver, home-manager, nixpkgs-gmessages-pr}@inputs:
  let
    system = "x86_64-linux";
    overlay-gmessages = final: prev: {
      mautrix-gmessages = (import nixpkgs-gmessages-pr {
        inherit system;
        inherit (final) config;
      }).mautrix-gmessages;
    };
  in {

    packages.x86_64-linux = (import ./packages nixpkgs.legacyPackages.x86_64-linux);

    nixosConfigurations.SENLPT-VIC01 = nixpkgs-unstable.lib.nixosSystem {
      inherit system;
      modules = [
        nixpkgs-unstable.nixosModules.notDetected
        {
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "anydesk" "corefonts" "intel-ocl" "samsung-unified-linux-driver" "spotify" "spotify-unwrapped" "vscode"
          ];
          nix = {
            settings.experimental-features = [ "nix-command" "flakes" ];
            registry = {
              nixpkgs.to = {
                type = "path";
                path = nixpkgs-unstable.legacyPackages.x86_64-linux.path;
              };
            };
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.victor = import ./users/victor/home.nix;
        }
        ./systems/SENLPT-VIC01/configuration.nix
      ];
    };

    nixosConfigurations.SENLPT-VIC14 = nixpkgs-unstable.lib.nixosSystem rec {
      inherit system;
      specialArgs = {
        inherit inputs;
        pkgs-stable = import nixpkgs {
          inherit system;
        };
      };
      modules = [
        nixpkgs-unstable.nixosModules.notDetected
        {
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "anydesk" "corefonts" "davinci-resolve" "samsung-unified-linux-driver" "spotify" "spotify-unwrapped" "vscode"
          ];
          nix = {
            settings.experimental-features = [ "nix-command" "flakes" ];
            registry = {
              nixpkgs.to = {
                type = "path";
                path = nixpkgs-unstable.legacyPackages.x86_64-linux.path;
              };
            };
          };
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.victor = import ./users/victor/home.nix;
        }
        {
          nixpkgs.overlays = [
            (final: prev: {
              freeshow = final.callPackage ./packages/freeshow.nix { };
            })
          ];
        }
        ./systems/SENLPT-VIC14/configuration.nix
      ];
    };

    nixosConfigurations.SENNAS01 = nixpkgs.lib.nixosSystem rec {
      inherit system;
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        nixpkgs.nixosModules.notDetected
        simple-nixos-mailserver.nixosModule
        {
          nixpkgs.config = {
            permittedInsecurePackages = [ "olm-3.2.16" ];
            allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              "unifi-controller" "unifi" "mongodb-ce"
            ];
          };
          nixpkgs.overlays = [ overlay-gmessages ];
          nix = {
            settings.experimental-features = [ "nix-command" "flakes" ];
            registry = {
              nixpkgs.to = {
                type = "path";
                path = nixpkgs.legacyPackages.x86_64-linux.path;
              };
            };
          };
        }
        ./modules/mautrix-gmessages
        ./systems/SENNAS01/configuration.nix
      ];
    };
  };
}
