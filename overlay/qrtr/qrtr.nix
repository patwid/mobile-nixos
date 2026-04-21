{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config }:

stdenv.mkDerivation {
  pname = "qrtr";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "qrtr";
    rev = "ae881086dfd29f828dcadb56e4b32a09fdc5c202";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [ meson ninja pkg-config ];

  meta = with lib; {
    description = "Qualcomm IPC Router userspace tools and library";
    homepage = "https://github.com/linux-msm/qrtr";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
