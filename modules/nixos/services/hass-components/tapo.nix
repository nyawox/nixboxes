{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python3Packages,
}:
buildHomeAssistantComponent rec {
  pname = "home-assistant-tapo-p100";
  version = "v2.11.0";
  src = fetchFromGitHub {
    owner = "petretiandrea";
    repo = "home-assistant-tapo-p100";
    rev = version;
    hash = "sha256-44tg0A8nDE2m0EflDnXobzN2CJXNKGoe+aTnbqFxD0s=";
  };

  propagatedBuildInputs = [
    (python3Packages.callPackage ../hass-dependencies/plugp100.nix {})
  ];

  meta = with lib; {
    changelog = "https://github.com/petretiandrea/home-assistant-tapo-p100/blob/${version}/CHANGELOG.md";
    description = "A custom integration to control Tapo devices from home assistant.";
    homepage = "https://github.com/petretiandrea/home-assistant-tapo-p100";
    # maintainers = with maintainers; [nyawox];
    license = licenses.mit;
  };
}
