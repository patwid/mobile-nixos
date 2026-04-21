{ stdenv, lib, fetchFromGitHub, meson, ninja, pkg-config, qrtr, zstd }:

stdenv.mkDerivation {
  pname = "tqftpserv";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "tqftpserv";
    rev = "0e78f03409df27465fea480aacba9eebe9cd9fe0";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [ qrtr zstd ];

  patches = [
    ./tqftpserv-firmware-path.diff
  ];

  # Don't install the systemd unit — mobile-nixos manages services itself.
  mesonFlags = [ "-Dsystemd-unit-prefix=" ];

  meta = with lib; {
    description = "Trivial File Transfer Protocol server over AF_QIPCRTR";
    homepage = "https://github.com/linux-msm/tqftpserv";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
