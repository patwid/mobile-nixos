{ stdenv
, lib
, fetchFromGitLab
, makeWrapper
, bluez
, coreutils
, gnugrep
, gnused
, gawk
, iproute2
, util-linux
}:

stdenv.mkDerivation rec {
  pname = "bootmac";
  version = "0.7.0";

  src = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "bootmac";
    rev = "v${version}";
    hash = "sha256-HMXre5oyVhit+nFJlqTiZtZi+GWjn5++2Js/JjqJWus=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    install -Dm755 bootmac $out/bin/bootmac
    wrapProgram $out/bin/bootmac \
      --prefix PATH : ${lib.makeBinPath [
        bluez
        coreutils
        gnugrep
        gnused
        gawk
        iproute2
        util-linux
      ]}
  '';

  meta = with lib; {
    description = "Assign deterministic MAC addresses at boot for Wi-Fi and Bluetooth";
    homepage = "https://gitlab.postmarketos.org/postmarketOS/bootmac";
    license = licenses.gpl3Plus;
  };
}
