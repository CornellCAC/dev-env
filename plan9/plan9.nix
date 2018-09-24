with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "acmeEnv";
  buildInputs = [
    plan9port
    
    #
    # Tools for editing
    #

    #
    # Scala
    #
    scalafmt
  ];
  src = null;
  shellHook = ''
    export PS1="[nix-shell:acme]$ "
    export PATH=$PATH:${./bin}
    alias acme="9 acme"
    alias sfmt="scalafmt --stdin"
    _acme () {
      \acme  -f ${plan9port}/plan9/font/luc/unicode.7.font "$@"
    }
    alias acme=_acme
  '';
}
