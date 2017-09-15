with import <nixpkgs> { };

buildEnv {
  name = "scala-env";
  paths = [
    ammonite
    boehmgc
    clang
    dbus # needed non-explicitly by vscode
    emacs
    git
    # idea.idea-ultimate # disabled temporarily
    less
    libunwind
    openjdk
    openssh
    re2
    rsync
    sbt
    stdenv
    syncthing # for syncrhonizing data between containers
    tmux
    unzip
    vscode
    zlib
  ];
  buildInputs = [ makeWrapper ];
  # TODO: better filter, use ammonite script?:
  postBuild = ''
  for f in $(ls -d $out/bin/* | grep "idea"); do
    sed -i '/IDEA_JDK/d' $f
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