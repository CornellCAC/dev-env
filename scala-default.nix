with import <nixpkgs> { };
let
  ideaLocal = stdenv.mkDerivation {
    name = "idea-local";
    buildInputs =  [ ];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/bin
      tar zxvf $src -C $out/
      ln -sf $out/idea-IU* $out/idea
      ln -sf $out/idea/bin/idea.sh $out/bin/idea
    '';
    # Note shellHooks is not used by nix-env
    shellHook = ''
      IDEA_JDK=/usr/lib/jvm/zulu-8-amd64
    '';
    src = fetchurl {
      url = https://download.jetbrains.com/idea/ideaIU-2017.2.4-no-jdk.tar.gz;
      sha256 = "15a4799ffde294d0f2fce0b735bbfe370e3d0327380a0efc45905241729898e3";
    };
  };
in { scalaEnv = buildEnv {
  name = "scala-env";
  paths = [
    ammonite
    boehmgc
    clang
    dbus # needed non-explicitly by vscode
    emacs
    git
    # idea.idea-ultimate # disabled temporarily
    ideaLocal
    less
    libunwind
    openjdk
    openssh
    re2
    rsync
    sbt
    stdenv
    syncthing # for syncrhonizing data between containers
    unzip
    vscode
    zlib
  ];
  # builder = builtins.toFile "builder.sh" ''
  #   source $stdenv/setup
  #   mkdir -p $out
  #   echo "" > $out/Done
  #   echo "Done setting up Scala environment."
  # '';
  buildInputs = [ makeWrapper ];
  # TODO: better filter, use ammonite script?:
  postBuild = ''
  # for f in $(ls -d $out/bin/* | grep "idea"); do
  #   sed -i '/IDEA_JDK/d' $f
  #   wrapProgram $f \
  #     --set IDEA_JDK "/usr/lib/jvm/zulu-8-amd64" \
  #     --set CLANG_PATH "${clang}/bin/clang" \
  #     --set CLANCPP_PATH "${clang}/bin/clang++"
  #   done
  '';

};}

#######################################
#
# Refs:
# https://stackoverflow.com/questions/46165918/how-to-get-the-name-from-a-nixpkgs-derivation-in-a-nix-expression-to-be-used-by/46173041#46173041
##