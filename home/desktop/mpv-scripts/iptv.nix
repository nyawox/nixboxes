{
  stdenvNoCC,
  pkgs,
}:
stdenvNoCC.mkDerivation {
  pname = "mpv-iptv";
  version = "unstable-2020-12-30";
  src = pkgs.fetchFromGitHub {
    owner = "gthreepw00d";
    repo = "mpv-iptv";
    rev = "b74d37a7aafa2acc168bf611aa4d1ef121f73de6";
    hash = "sha256-REiCbm7SczFjwUyE5DyQ9P39lzW4iW9aOilI7m6QS4g=";
  };

  dontBuild = true;
  dontCheck = true;

  installPhase = ''
    mkdir -p $out/share/mpv/scripts/mpv-iptv
    cp -r iptv.lua $out/share/mpv/scripts/mpv-iptv/
  '';
  passthru.scriptName = "mpv-iptv";
}
