with import <nixpkgs> {};
let
  version = "7.5.1";
in  
stdenv.mkDerivation {
  pname = "gurobi";
  version = "$version";
  name = "gurobi-${version}";
  description = "A commercial convex and mixed integer optimization solver";
  src = fetchurl {
    url = http://packages.gurobi.com/7.5/gurobi7.5.1_linux64.tar.gz;
    sha256 = "7f5c8b0c3d3600ab7a1898f43e238a9d9a32ac1206f2917fb60be9bbb76111b6";
  };
  installPhase = ''
    cp -R linux64 $out
    patchelf --set-interpreter \
      ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 $out/bin/*
    patchelf --set-rpath ${stdenv.glibc}/lib $out/bin/*
  '';
  GUROBI_HOME = "$out";
}