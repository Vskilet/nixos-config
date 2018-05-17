self: super:
{
  riot-web = super.riot-web.override {
    conf = ''
      {
        "default_hs_url": "https://matrix.sene.ovh",
        "default_is_url": "https://vector.im",
        "brand": "SENE-NET",
        "default_theme": "dark"
      }
    '';
  };
}
