with import <nixpkgs> { };
# For testing local nixpkgs clone, swap with above
# with import ((builtins.getEnv "HOME") + "/workspace/nixpkgs") { }; # or:
# with import "../nixpkgs" { };
# Note taht the above are not accessible during docker build
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
 ncursesLocal = stdenv.mkDerivation {
    name = "ncurses-local";
    buildInputs =  [ncurses];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out
    '';
    src = null;
    installPhase = ''
      # Hack around lack of libtinfo in NixOS
      ln -s ${ncurses.out}/lib/libncursesw.so.5 $out/lib/libtinfo.so.5
      ln -s ${stdenv.cc.libc}/lib/libpthread.so.0 $out/lib/libpthread.so.0
    '';
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
in { brandonDevEnv = buildEnv {
  name = "brandon-dev-env";
  paths = [
    ammonite
    awscli
    # bash-completion # disabled, using system bash
    boehmgc
    clang
    curl
    docker
    docker_compose
    # dotty # (Tentative Scala 3 compiler; see dottyLocal above for alternative)
    dbus # needed non-explicitly by vscode
    emacs
    es
    gdb
    git
    git-lfs
    # git-secrets
    gnumake
    gnupg
    gradle
    # herokuLocal # no stable versioning/checksum
    # idea.idea-ultimate # disabled temporarily due to runtime issues
    # idris # currently has trouble building
    # ideaLocal
    less
    libunwind
    maven
    mlton
    # nix # could cause conflicts
    ncursesLocal
    nodejs-10_x
    openjdk
    openssh
    phantomjs2
    re2
    ripgrep
    rsync
    sbt
    scala
    scalafmt
    shellcheck
    singularity
    stdenv
    syncthing # for syncrhonizing data between containers
    tmux
    tree
    unzip
    # visualvm # character issues currently, likely needs idea-jdk
    # vscode # we no longer install vscode by default due to how WSL2 provides Windows code,
             # though we note it can it could always be used via `nix-shell -p vscode` if desired
    which
    yarn
    zlib

    #
    # For spacemacs
    #
    source-code-pro

    #
    #Haskell/Eta support
    #
    ghc # use stack instead, once working
    cabal-install
    direnv # for nix-shell/emacs integration
    stack # The Haskell tool stack
    # haskellPackages.ghc-mod # currently broken due to broken cabal-helper
    # haskellPackages.codex # works with hasktags; currently broken
    haskellPackages.hasktags
    haskellPackages.hoogle
    # haskellPackages.hoogle-index # currently broken due to missing deps
    haskellPackages.hpack
    haskellPackages.hlint
    # haskellPackages.intero # fails, but works with cabal install ...
    haskellPackages.stylish-haskell
    #
    # Python support
    #
    # Disabling the following until pipenv works
    # python36Full
    # python36Packages.virtualenv
    # python36Packages.pip
    # python36Packages.ipython
    # nixpip # installed seperately: https://github.com/badi/nix-pip
    mypy

    #
    # Rust support
    #
    rustup
    # cargo # collides with rustup here, but can be installed via rustup
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
    # if [ ! -e $out/lib/libunwind-generic.a ] ; then
    #  rm $out/lib/libunwind-generic.a
    # fi
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