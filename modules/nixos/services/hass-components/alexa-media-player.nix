{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python3Packages,
}:
buildHomeAssistantComponent rec {
  pname = "alexa-media-player";
  version = "v4.7.9";
  src = fetchFromGitHub {
    owner = "custom-components";
    repo = "alexa_media_player";
    rev = version;
    hash = "sha256-iFn08HFZyv6W5G56WSJBBJjYtkwL8Vavc4KoyHowKNw=";
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
