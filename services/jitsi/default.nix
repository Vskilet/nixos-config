{ pkgs, config, lib, ... }:

{
  services.jitsi-meet = {
    enable = true;
    hostName = "meet.sene.ovh";
    config = {
      enableWelcomePage = true;
      prejoinPageEnabled = true;
      defaultLang = "fr";
      enableNoisyMicDetection = false;
    };
    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
      DISABLE_VIDEO_BACKGROUND = true;
      PROVIDER_NAME = "sene.ovh";
      DISABLE_JOIN_LEAVE_NOTIFICATIONS = true;
    };
  };
  services.jitsi-videobridge = {
    openFirewall = true;
    nat = {
      localAddress = "192.168.1.136";
      #config.networking.interfaces."enp2s0".ipv4.addresses.0.address;
      publicAddress = "128.78.187.125";
      #"${pkgs.dnsutils}/bin/dig +short myip.opendns.com @208.67.222.222";
    };
  };
  boot.kernel.sysctl."net.core.rmem_max" = 10485760;

  services.nginx.virtualHosts."meet.sene.ovh" = {
    enableACME = true;
    forceSSL   = true;
    extraConfig = ''
      more_set_headers "X-Frame-Options: ALLOW";
    '';
  };
}
