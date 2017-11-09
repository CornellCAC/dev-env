#
# TODO: consider using a shell-specific version of pathdef.m
# TODO: instead of relying on a default in Documents/MATLAB
#

with import <nixpkgs> {};
let
  matlabGcc = gcc49;
  gurobiPlatform = "linux64";
  myGurobi = (import ../../packages/gurobi/default.nix);
in
stdenv.mkDerivation {
  name = "impureMatlabEnv";
  inherit matlabGcc;
  buildInputs = [
    matlabGcc
    makeWrapper
    zlib
  ];

  libPath = stdenv.lib.makeLibraryPath [
    mesa_glu
    ncurses
    xorg.libXi
    xorg.libXext
    xorg.libXmu
    xorg.libXp
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libX11
    zlib
  ];
  src = null;
  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/MATLAB/bin/glnxa64:${xorg.libXxf86vm}/lib
    export PATH=$PATH:/opt/MATLAB/bin
    export GUROBI_HOME="${myGurobi.out}/${gurobiPlatform}"
    export GUROBI_PATH="${myGurobi.out}/${gurobiPlatform}"
    export GRB_LICENSE_FILE="$HOME/gurobi_CAC.lic"
  '';
}
