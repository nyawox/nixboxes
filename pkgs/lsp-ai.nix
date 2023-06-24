{
  lib,
  rustPlatform,
  fetchCrate,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "lsp-ai";
  version = "0.6.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-avc4QACAbb/JGdqLQ8WrB33B7m2XNrYKbEczgvMRmnE=";
  };

  OPENSSL_NO_VENDOR = 1;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-LjV8YkeSIzMYkAvhsjDJQxQWVgzUQLKl1daJ1cuU4OA=";

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
