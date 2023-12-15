{
  stdenv,
  pkgs,
}:
stdenv.mkDerivation {
  pname = "recfsusb2n";
  version = "unstable-2018-02-04";
  src = pkgs.fetchFromGitHub {
    owner = "sh0";
    repo = "recfsusb2n";
    rev = "dd91cfca797eeb3cb25d27c0c50664fbd7ad8fa2";
    hash = "sha256-uWhdRBKRzefN9Yu5XZcN281rxSTWHVFGd1VIG3Wpmvo=";
  };
  nativeBuildInputs = with pkgs; [boost];
  buildPhase = ''
    cd src
    make
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp recfsusb2n $out/bin/
  '';
  patches = [./http.patch];
}
