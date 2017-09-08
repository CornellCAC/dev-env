let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
in rec {
  scalaEnv = stdenv.mkDerivation rec {
    name = "scala-env";
    builder = "./scala-build.sh";
    shellHook = ''
    alias cls=clear
    '';
    CLANG_PATH = pkgs.clang + "/bin/clang";
    CLANGPP_PATH = pkgs.clang + "/bin/clang++";
    IDEA_JDK = pkgs.openjdk + "/lib/openjdk";
    buildInputs = with pkgs; [
      stdenv
      sbt
      openjdk
      boehmgc
      emacs
      less
      libunwind
      re2
      clang
      zlib
      ammonite
    ];
  };
} 
