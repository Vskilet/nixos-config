self: super:
{
  element-web = super.element-web.override {
    conf = {
      default_server_config = {
        "m.homeserver" = {
          base_url = "https://matrix.sene.ovh";
          server_name = "matrix.sene.ovh";
        };
        "m.identity_server" = {
          base_url = "https://vector.im";
        };
      };
      brand = "SENE-NET";
      default_theme = "dark";
      defaultCountryCode = "FR";
      integrations_ui_url = "https://dimension.t2bot.io/riot";
      integrations_rest_url = "https://dimension.t2bot.io/api/v1/scalar";
      integrations_widgets_urls = ["https://dimension.t2bot.io/widgets"];
    };
  };
}
