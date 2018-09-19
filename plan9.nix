with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "plan9Env";
  buildInputs = [
    plan9port
  ];
  src = null;
  shellHook = ''
    export PATH=$PATH:${plan9port}/plan9/bin
    _acme () {
      \acme  -f ${plan9port}/plan9/font/luc/unicode.7.font "$@"
    }
    alias acme=_acme
  '';
}
