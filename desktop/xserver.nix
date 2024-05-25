{ config, lib, pkgs, ... }:
{
   environment.variables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      TERMINAL = "alacritty";
   };

   services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
   };
   services.displayManager.defaultSession = "none+i3";
   services.xserver = {
      enable = true;
      xkb = {
         layout = "us,fr";
         variant = "intl,";
         options = "grp:win_space_toggle";
      };
      desktopManager = {
         xterm.enable = false;
      };
      displayManager.sessionCommands = ''
         ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
      '';
      videoDrivers = [ "displaylink" "modesetting" ];
      windowManager.i3 = {
         enable = true;
         package = pkgs.i3-gaps;
         configFile = ../../misc/i3.config;
         extraPackages = with pkgs; [
            dmenu #application launcher most people use
            i3status # gives you the default i3 status bar
            i3lock #default i3 screen locker
            i3blocks #if you are planning on using i3blocks over i3status
            polybar xss-lock betterlockscreen dunst rofi i3-auto-layout
            rofi-pass rofi-power-menu
            alacritty
            xclip
         ];
      };
   };
   services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;
   };
   services.autorandr = {
      enable = true;
      defaultTarget = "laptop";
      hooks = {
         postswitch = {
            "1-update-wallpaper" = "${pkgs.feh}/bin/feh --bg-scale /home/victor/Images/Wallpapers/nixos.png";
            "2-update-lockscreen" = "${pkgs.betterlockscreen}/bin/betterlockscreen --blur 1.0 -u /home/victor/Images/Wallpapers/gears.png";
         };
      };
      profiles = {
         "desk" = {
            fingerprint = {
               eDP-1 = "00ffffffffffff0030e4fc030000000000170104951f11780aa3e59659558e271f505400000001010101010101010101010101010101482640a460841a303020250035ae10000019000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503134305744322d54504231002a";
               DVI-I-1-1 = "00ffffffffffff0030aeab6101010101081d010380331d782e27b5a4574c9f260f5054bdcf00714f8180818c9500b300d1c001010101023a801871382d40582c4500fd1e1100001e000000ff0056333033334c544d0a20202020000000fd00324b1e5311000a202020202020000000fc004c454e20543233692d31300a20017902031ef14b010203040514111213901f230907078301000065030c001000011d007251d01e206e285500fd1e1100001e8c0ad08a20e02d10103e9600fd1e110000188c0ad090204031200c405500fd1e110000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000052";
               DVI-I-2-2 = "00ffffffffffff0030aeab6157464e460e1e010380331d782e27b5a4574c9f260f5054bdcf00714f8180818c9500b300d1c001010101023a801871382d40582c4500fd1e1100001e000000ff0056333035464e46570a20202020000000fd00324b1e5311000a202020202020000000fc004c454e20543233692d31300a20013202031ef14b010203040514111213901f230907078301000065030c001000011d007251d01e206e285500fd1e1100001e8c0ad08a20e02d10103e9600fd1e110000188c0ad090204031200c405500fd1e110000180000000000000000000000000000000000000000000000000000000000000000000000000000000000000052";
            };
            config = {
               eDP-1 = {
                  enable = true;
                  mode = "1600x900";
                  position = "0x0";
                  crtc = 2;
                  rotate = "normal";
               };
               DVI-I-1-1 = {
                  enable = true;
                  mode = "1920x1080";
                  position = "1600x0";
                  crtc = 1;
                  rotate = "left";
               };
               DVI-I-2-2 = {
                  enable = true;
                  mode = "1920x1080";
                  position = "2680x589";
                  primary = true;
                  crtc = 0;
                  rotate = "normal";
               };
            };
         };
         "laptop" = {
            fingerprint = {
               eDP-1 = "00ffffffffffff0030e4fc030000000000170104951f11780aa3e59659558e271f505400000001010101010101010101010101010101482640a460841a303020250035ae10000019000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503134305744322d54504231002a";
            };
            config = {
               eDP-1 = {
                  enable = true;
                  mode = "1600x900";
                  position = "0x0";
                  rate = "60.00";
                  crtc = 0;
                  rotate = "normal";
               };
            };
         };
         "tele" = {
            fingerprint = {
               eDP-1 = "00ffffffffffff0030e4fc030000000000170104951f11780aa3e59659558e271f505400000001010101010101010101010101010101482640a460841a303020250035ae10000019000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503134305744322d54504231002a";
               HDMI-1 = "00ffffffffffff004c2d670b3336333002190103803c22782a9791a556549d250e5054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c450056502100001e011d007251d01e206e28550056502100001e000000fd00324b1e5111000a202020202020000000fc00533237443339300a2020202020010302031af14690041f130312230907078301000066030c00100080011d00bc52d01e20b828554056502100001e8c0ad090204031200c4055005650210000188c0ad08a20e02d10103e9600565021000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061";
            };
            config = {
               eDP-1 = {
                  enable = true;
                  mode = "1600x900";
                  position = "1920x0";
                  rate = "60.00";
                  crtc = 1;
                  rotate = "normal";
               };
               HDMI-1 = {
                  enable = true;
                  mode = "1920x1080";
                  position = "0x0";
                  rate = "60.00";
                  crtc = 0;
                  primary = true;
                  rotate = "normal";
               };
            };
         };
      };
   };

   environment.etc."i3status.conf".source = ../../misc/i3status.config;
   environment.etc."alacritty.toml".source = ../../misc/alacritty.toml;

}
