{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "poppins";
  version = "v4.003";

  src = fetchFromGitHub {
    owner = "itfoundry";
    repo = "poppins";
    rev = "311d7fa87bdf7cd5cc4210a91bac56d5512a3013";
    hash = "sha256-7+RQHYxNFqOw2EeS2hgrbK/VbUAiPorUtkyRb5MFh5w=";
  };

  nativeBuildInputs = [unzip];

  installPhase = ''
    runHook preInstall
    unzip products/Poppins-4.003-GoogleFonts-TTF.zip
    unzip products/PoppinsLatin-5.001-Latin-TTF.zip
    install -Dm644 *.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = {
    description = "Poppins, a Devanagari + Latin family for Google Fonts.";
    homepage = "https://github.com/itfoundry/Poppins/";
    license = lib.licenses.ofl;
    # maintainers = with lib.maintainers; [nyawox];
    platforms = lib.platforms.all;
  };
}
