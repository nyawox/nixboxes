{
  self,
  inputs,
  outputs,
  stateVersion,
  ...
}:
let
  gen = import ./gen.nix {
    inherit
      self
      inputs
      outputs
      stateVersion
      ;
  };
in
{
  inherit (gen) mkLinux;
}
