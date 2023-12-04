{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python3Packages,
}:
buildHomeAssistantComponent rec {
  pname = "alexa-media-player";
  version = "v4.8.0";
  src = fetchFromGitHub {
    owner = "custom-components";
    repo = "alexa_media_player";
    rev = version;
    hash = "sha256-AnHQ9mLTf8QSbsqN2SXTOVhx7gGyNwxg5TydzfGEqF0=";
  };

  propagatedBuildInputs = with python3Packages; [
    alexapy
    packaging
    wrapt
  ];

  meta = with lib; {
    description = "This is a custom component to allow control of Amazon Alexa devices in Home Assistant using the unofficial Alexa API.";
    homepage = "https://github.com/custom-components/alexa_media_player";
    # maintainers = with maintainers; [nyawox];
    license = licenses.asl20;
  };
}
