{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  owner = "dustinhu93";
  domain = "nature_remo";
  version = "unstable-2023-10-01";
  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-nature-remo";
    rev = "8d14621cd729b1086595e54aead067ea53a4f7c8";
    hash = "sha256-iqeDUWEX2AW6nDv0Yefoy5Kdw7PyO2DeYp2tmS4tqcM=";
  };

  meta = with lib; {
    description = "Nature Remo integration for Home Assistant";
    homepage = "https://github.com/dustinhu93/hass-nature-remo";
    # maintainers = with maintainers; [nyawox];
    license = licenses.mit;
  };
}
