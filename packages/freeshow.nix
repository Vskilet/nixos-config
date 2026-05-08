{
  lib,
  fetchurl,
  stdenv,
  undmg,
  appimageTools,
}:

let
  pname = "freeshow";
  version = "1.6.0";
  src =
    fetchurl
      {
        x86_64-linux = {
          url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}-x86_64.AppImage";
          hash = "sha256-EkjnNvjLa66fmRLy75RkuSAPVYK8bBZZ0LbhlVhrltw=";
        };
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.system}");

  appimageContents = appimageTools.extract { inherit pname version src; };

  meta = {
    description = "Free and open-source, user-friendly presenter software";
    homepage = "https://freeshow.app";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vskilet ];
    mainProgram = "freeshow";
    platforms = [
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };

in
appimageTools.wrapType2 {
  inherit
    pname
    version
    src
    meta
    ;

  extraInstallCommands = ''
    mkdir -p $out/share/{applications,freeshow}
    cp -a ${appimageContents}/{locales,resources} $out/share/freeshow
    cp -a ${appimageContents}/usr/share/icons $out/share
    install -Dm 444 ${appimageContents}/freeshow.desktop $out/share/applications
    substituteInPlace $out/share/applications/freeshow.desktop \
    --replace-warn 'Exec=AppRun' 'Exec=freeshow'
  '';

}
