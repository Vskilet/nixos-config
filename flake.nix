{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "flake:nixpkgs/nixos-unstable";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-24_05.follows = "nixpkgs";
      };
    };
    nix-matrix-appservices = {
      url = "gitlab:coffeetables/nix-matrix-appservices";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, simple-nixos-mailserver, nix-matrix-appservices }: {

    nixosConfigurations.SENLPT-VIC01 = nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixpkgs-unstable.nixosModules.notDetected
        {
          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "anydesk" "corefonts" "davinci-resolve" "displaylink" "intel-ocl" "samsung-unified-linux-driver" "spotify" "spotify-unwrapped" "unifi-controller" "vscode" "zoom"
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
        ./systems/SENLPT-VIC01/configuration.nix
      ];
    };

    nixosConfigurations.SENNAS01 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixpkgs.nixosModules.notDetected
        nix-matrix-appservices.nixosModule
        simple-nixos-mailserver.nixosModule
        {
          nixpkgs.config = {
            permittedInsecurePackages = [ "olm-3.2.16" ];
            allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              "unifi-controller" "unifi" "mongodb"
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
