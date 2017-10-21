with import <nixpkgs> {};
let
  version = "7.5.1";
  GUROBI_HOME = "$out/linux64";
in  
stdenv.mkDerivation {
  name = "gurobi-${version}";

  src = fetchurl {
    url = http://packages.gurobi.com/7.5/gurobi7.5.1_linux64.tar.gz;
    sha256 = "7f5c8b0c3d3600ab7a1898f43e238a9d9a32ac1206f2917fb60be9bbb76111b6";
  };

  installPhase = ''
    mkdir -p $out/bin
    patchelf --set-interpreter \
      ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 linux64/bin/*
    patchelf --set-rpath ${stdenv.glibc}/lib linux64/bin/*
    ln -sf linux64/bin/* $out/bin/
  '';
  shellHook = ''
    GUROBI_HOME="${GUROBI_HOME}"
    export GUROBI_PATH="${GUROBI_HOME}"
  '';
      # export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
      # export PATH="${PATH}:${GUROBI_HOME}/bin"

}