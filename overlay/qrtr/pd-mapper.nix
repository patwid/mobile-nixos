{ stdenv, lib, fetchFromGitHub, qrtr, xz }:

stdenv.mkDerivation {
  pname = "pd-mapper";
  version = "unstable-2025-01-14";

  buildInputs = [ qrtr xz ];

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "pd-mapper";
    rev = "5ecd2fe926aca7abfe40724177f63b942cff3947";
    hash = lib.fakeHash;
  };

  patches = [
    ./pd-mapper-firmware-path.diff
  ];

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "Qualcomm PD mapper";
    homepage = "https://github.com/linux-msm/pd-mapper";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
