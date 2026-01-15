{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-25_05.follows = "nixpkgs";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-25_05.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver, home-manager }@inputs: {

    packages.x86_64-linux = (import ./packages nixpkgs.legacyPackages.x86_64-linux);

    nixosConfigurations.SENLPT-VIC01 = nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
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

    nixosConfigurations.SENLPT-VIC14 = nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
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
        ./systems/SENLPT-VIC14/configuration.nix
      ];
    };

    nixosConfigurations.SENNAS01 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
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
        ./systems/SENNAS01/configuration.nix
      ];
    };
  };
}
