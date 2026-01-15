{ config, lib, pkgs, ... }:
{
  environment = {
    variables = {
      TERMINAL = "alacritty";

      SDL_VIDEODRIVER = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GTK_USE_PORTAL = "0";
    };
    etc = {
      "sway.conf".source = ./sway.conf;
      "sway/config".source = ./sway.conf;
      "i3status.conf".source = ./i3status.config;
      "xdg/waybar/config".source = ./waybar.config;
      "alacritty.toml".source = ./alacritty.toml;
    };
  };

  programs.regreet = {
    enable = true;
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
    theme = {
      name = "Numix";
      package = pkgs.numix-gtk-theme;
    };
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      alacritty
      clipman
      glib
      grim
      hyprpicker
      i3status waybar kanshi
      mako
      rofi rofi-pass rofi-power-menu
      slurp
      swayidle
      swaylock
      wdisplays
      wl-clipboard
      wl-screenrec
      wofi

      kdePackages.breeze
      numix-gtk-theme
      numix-icon-theme
      yaru-theme
    ];
  };
  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "qt5ct";
  };
  security.polkit.enable = true;
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.pulseaudio.package = pkgs.pulseaudioFull;
}
