with import <nixpkgs> { };

buildEnv {
  name = "scala-env";
  paths = [
    ammonite
    boehmgc
    clang
    emacs
    idea.idea-ultimate
    less
    libunwind
    openjdk
    re2
    sbt
    stdenv
    unzip
    zlib
  ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
  for f in $(ls -d $out/bin/*); do
    wrapProgram $f \
      --set IDEA_JDK "/usr/lib/jvm/zulu-8-amd64" \
      --set CLANG_PATH "${clang}/bin/clang" \
      --set CLANCPP_PATH "${clang}/bin/clang++"
    done
  '';
}

#######################################3
#
# Refs:
# https://stackoverflow.com/questions/46165918/how-to-get-the-name-from-a-nixpkgs-derivation-in-a-nix-expression-to-be-used-by/46173041#46173041
#
#