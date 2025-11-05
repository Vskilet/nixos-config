{pkgs, ...}: {
  imports = [
    #../../home/core.nix
  ];

  programs.git = {
    userName = "Victor SENE";
    userEmail = "victor@sene.ovh";
		signing = {
			key = "3ADFA1562B2E34D7";
			signByDefault = true;
		};
  };
}
