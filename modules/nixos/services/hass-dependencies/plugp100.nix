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
  fetchFromGitHub,
}:
buildPythonPackage rec {
  pname = "plugp100";
  version = "v3.14.0";

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

  doCheck = false;

  pythonImportsCheck = ["plugp100"];

  meta = with lib; {
    description = "Work in progress implementation of tapo protocol in python.";
    homepage = "https://github.com/petretiandrea/plugp100";
    license = licenses.gpl3;
    # maintainers = with maintainers; [ nyawox ];
  };
}
