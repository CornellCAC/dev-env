with import <nixpkgs> {};
let
  matlabGcc = gcc49;
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
  '';
}
