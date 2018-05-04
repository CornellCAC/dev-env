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
      url = https://download.jetbrains.com/idea/ideaIU-2017.2.5-no-jdk.tar.gz;
      sha256 = "6649ec545093be46ebf2bf2d76e4b67597b2c92ea9ad80fe354db130994de45e";
    };
  };
  dottyLocal = stdenv.mkDerivation {
    name = "dotty-local";
    buildInputs =  [ ];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/bin
      tar zxvf $src -C $out/
      ln -sf $out/dotty-* $out/dotty
      ln -sf $out/dotty/bin/* $out/bin/
    '';
    src = fetchurl {
      url = https://github.com/lampepfl/dotty/releases/download/0.3.0-RC2/dotty-0.3.0-RC2.tar.gz;
      sha256 = "1359843e19ac25b1dc465bfb61d84aeb507476bca57a46d90a111454e123ab29";
    };
  };
  herokuLocal = stdenv.mkDerivation {
    name = "heroku-local";
    buildInputs =  [ ];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/bin
      tar zxvf $src -C $out/
      ln -sf $out/heroku-* $out/heroku
      ln -sf $out/heroku/bin/* $out/bin/
    '';
    src = fetchurl {
      url = https://cli-assets.heroku.com/heroku-cli/channels/stable/heroku-cli-linux-x64.tar.gz;
      sha256 = "d6b8217ce15f3ba61a1872b8b95f353fdde1f03f885a0eb99141e45ae7426516";
    };
  };
in { scalaEnv = buildEnv {
  name = "scala-env";
  paths = [
    ammonite
    ats # Needed to bootstrap ats2
    # ats2 # Plan to use bleeding edge for now
    awscli
    # bash-completion # disabled, using system bash
    boehmgc
    clang
    docker
    dotty # (Tentative Scala 3 compiler; see dottyLocal above for alternative)
    dbus # needed non-explicitly by vscode
    emacs
    gdb
    git
    git-lfs
    gnumake
    gnupg
    gradle
    # herokuLocal # no stable versioning/checksum
    idea.idea-ultimate # disabled temporarily
    idris
    # ideaLocal
    less
    libunwind
    maven
    mlton
    nodejs-8_x
    openjdk
    openssh
    phantomjs2
    re2
    rsync
    sbt
    scala
    shellcheck
    stdenv
    syncthing # for syncrhonizing data between containers
    tinycc # For ATS2 scripting
    unzip
    # visualvm # character issues currently, likely needs idea-jdk
    vscode
    yarn
    zlib

    #
    #Haskell/Eta support
    #
    ghc # use stack instead, once working
    stack # The Haskell tool stack
    haskellPackages.hpack
    
    #
    # Python support
    #
    # Disabling the following until pipenv works
    # python36Full
    # python36Packages.virtualenv
    # python36Packages.pip
    # python36Packages.ipython
    # nixpip # installed seperately: https://github.com/badi/nix-pip
    
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
    # we remove a dead symbolic link, which currently causes nix to break:
    if [ ! -e $out/lib/libunwind-generic.a ] ; then
      rm $out/lib/libunwind-generic.a
    fi
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