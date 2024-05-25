{ config, lib, pkgs, ... }:
{
  environment = {
    variables = {
      QT_QPA_PLATFORM = "wayland";
      TERMINAL = "alacritty";

      SDL_VIDEODRIVER = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
    etc = {
      "sway.conf".source = ./sway.conf;
      "i3status.conf".source = ./i3status.config;
      "xdg/waybar/config".source = ./waybar.config;
      "alacritty.toml".source = ./alacritty.toml;
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
      i3status waybar kanshi
      mako
      rofi rofi-pass rofi-power-menu
      slurp
      swayidle
      swaylock
      wdisplays
      wl-clipboard

      breeze-icons
      numix-gtk-theme
      numix-icon-theme
      qt5.qtwayland
      yaru-theme
    ];
  };
  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "qt5ct";
  };
  security.polkit.enable = true;
  xdg.portal.wlr.enable = true;
}
