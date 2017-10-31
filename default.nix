with import <nixpkgs> {};
pkgs.stdenv.mkDerivation rec {
  name = "di-playground";
  # get deps
  buildInputs = [ swift ];
  src = ./.;

  buildPhase = ''
    swift build
  '';

  # test
  doCheck = true;
  checkPhase = ''
    swift test
  '';
}

