{
  lib,
  rustPlatform,
  fetchCrate,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "lsp-ai";
  version = "0.3.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-zIZ1cGHZsiP54QylukmTOQWKNB4UE8vUEEGyfaeUq4M";
  };

  OPENSSL_NO_VENDOR = 1;

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  cargoHash = "sha256-kItUKhf0k9Bwt5h7hSL1sMpvhwJyPe/9E3PjtKB/UpQ=";

  doCheck = false;

  # buildFeatures = [
  #   "llama_cpp"
  #   "metal"
  # ];

  meta = with lib; {
    description = "An open-source language server that serves as a backend for AI-powered functionality";
    homepage = "https://github.com/SilasMarvin/lsp-ai";
    license = licenses.mit;
    mainProgram = "lsp-ai";
  };
}
