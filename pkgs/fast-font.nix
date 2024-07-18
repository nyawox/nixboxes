{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "fast-font";
  version = "unstable-2024-06-19";

  src = fetchFromGitHub {
    owner = "Born2Root";
    repo = "Fast-Font";
    rev = "9523f7096cd7a024bc0098c5bdd9bb35e8ec2d70";
    hash = "sha256-BGCorq2v2jGr49wEZcPcGbGOHzDeyZTO2uPuXtZ2k7o=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Born2Root/Fast-Font";
    description = "A font to help you read faster.";
    license = licenses.mit;
    maintainers = [];
  };
}
