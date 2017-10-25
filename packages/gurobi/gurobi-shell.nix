with import <nixpkgs> {};
let
  myGurobi = (import ./default.nix);
in stdenv.mkDerivation  {
  name = "gurobi-shell";
  buildInputs = [ myGurobi ];
  shellHook = ''
   export GUROBI_HOME="${myGurobi.out}"
   export GUROBI_PATH="${myGurobi.out}"
  '';
      # export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
}  