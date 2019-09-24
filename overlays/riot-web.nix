self: super:
{
  riot-web = super.riot-web.override {
    conf = ''
      {
        "default_hs_url": "https://matrix.sene.ovh",
        "default_is_url": "https://vector.im",
        "brand": "SENE-NET",
        "default_theme": "dark",
        "integrations_ui_url": "https://dimension.t2bot.io/riot",
        "integrations_rest_url": "https://dimension.t2bot.io/api/v1/scalar",
        "integrations_widgets_urls": ["https://dimension.t2bot.io/widgets"],
        "integrations_jitsi_widget_url": "https://dimension.t2bot.io/widgets/jitsi"
      }
    '';
  };
}
