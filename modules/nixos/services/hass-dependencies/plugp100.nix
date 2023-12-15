{
  lib,
  buildPythonPackage,
  certifi,
  jsons,
  requests,
  aiohttp,
  semantic-version,
  cryptography,
  scapy,
  setuptools,
  fetchFromGitHub,
}:
buildPythonPackage rec {
  pname = "plugp100";
  version = "v3.14.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "petretiandrea";
    repo = "plugp100";
    rev = version;
    hash = "sha256-W8bDqdKW9dAa6PtR/LSZZlxtELkPNJkT3szh36kU6ss=";
  };

  propagatedBuildInputs = [
    certifi
    jsons
    requests
    aiohttp
    semantic-version
    cryptography
    scapy
  ];

  nativeBuildInputs = [
    setuptools
  ];

  doCheck = false;

  pythonImportsCheck = ["plugp100"];

  # get_host is deprecated and removed from urllib3 2.x
  patchPhase = ''
    substituteInPlace plugp100/protocol/klap_protocol.py \
      --replace 'urllib3.get_host(self._base_url)' 'urllib3.util.parse_url(self._base_url)'
  '';

  meta = with lib; {
    description = "Work in progress implementation of tapo protocol in python.";
    homepage = "https://github.com/petretiandrea/plugp100";
    license = licenses.gpl3;
    # maintainers = with maintainers; [ nyawox ];
  };
}
