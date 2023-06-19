self: super: {

  mautrix-signal = super.mautrix-signal.overridePythonAttrs (oA: rec {
    pname = "mautrix-signal";
    version = "0.4.3";

    src = super.fetchFromGitHub {
      owner = "mautrix";
      repo = "signal";
      rev = "refs/tags/v${version}";
      sha256 = "sha256-QShyuwHiWRcP1hGkvCQfixvoUQ/FXr2DYC5VrcMKX48=";
    };

    propagatedBuildInputs = with super.python3.pkgs; [
      commonmark
      aiohttp
      aiosqlite
      asyncpg
      attrs
      commonmark
      mautrix
      phonenumbers
      pillow
      prometheus-client
      pycryptodome
      python-olm
      python-magic
      qrcode
      ruamel-yaml
      unpaddedbase64
      yarl
    ];
  });
}
