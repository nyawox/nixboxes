{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  python3Packages,
}:
buildHomeAssistantComponent rec {
  owner = "petretiandrea";
  domain = "tapo";
  version = "unstable-2013-11-26";
  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-tapo-p100";
    rev = "a8aee7f704294d85078a30e3f0fb4e7328fae139";
    hash = "sha256-pN2wWCAEk+PIp74eX8wAX2irrzWmEd8srq23/xpjgDI=";
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
