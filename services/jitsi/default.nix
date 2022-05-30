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
      localAddress = "172.16.1.3";
      #config.networking.interfaces."eno1".ipv4.addresses.0.address;
      publicAddress = "128.78.187.125";
      #"${pkgs.dnsutils}/bin/dig +short myip.opendns.com @208.67.222.222";
    };
    config = {
      videobridge.http-servers.private.port = 8070;
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
