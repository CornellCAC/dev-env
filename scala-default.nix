let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  idea_name = assert pkgs.jetbrains.idea-ultimate.name != ""; pkgs.jetbrains.idea-ultimate.name;
in rec {
  scalaEnv = stdenv.mkDerivation rec {
    name = "scala-env";
    builder = "./scala-build.sh";
    shellHook = ''
    alias cls=clear
    '';
    CLANG_PATH = pkgs.clang + "/bin/clang";
    CLANGPP_PATH = pkgs.clang + "/bin/clang++";
    # A bug in the nixpkgs openjdk (#29151) makes us resort to Zulu OpenJDK for IDEA:
    # IDEA_JDK = pkgs.openjdk + "/lib/openjdk";
    PATH = "${pkgs.jetbrains.idea-ultimate}/${idea_name}/bin:$PATH";
    #IDEA_JDK = /usr/lib/jvm/zulu-8-amd64;
    IDEA_JDK = /usr/lib/jvm/java-8-openjdk-amd64;
    buildInputs = with pkgs; [
      ammonite
      boehmgc
      clang
      emacs
      jetbrains.idea-ultimate
      less
      libunwind
      openjdk
      re2
      sbt
      stdenv
      unzip
      zlib
    ];
  };
} 
