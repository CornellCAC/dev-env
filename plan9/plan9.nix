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
    _acme () {
      \9 acme  -F ${plan9port}/plan9/font/fixed/unicode.7x13.font "$@"
    }
    alias acme=_acme
  '';
}
