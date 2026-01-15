{pkgs, lib, ...}: {
  imports = [
    #../../home/core.nix
  ];

  home = {
    homeDirectory = "/home/victor";
    username = "victor";
    stateVersion = "25.05";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Victor SENE";
      email = "victor@sene.ovh";
    };
    signing = {
      key = "3ADFA1562B2E34D7";
      signByDefault = true;
    };
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
