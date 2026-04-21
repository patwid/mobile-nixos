{ stdenv, lib, fetchFromGitHub, udev, qrtr, qmic }:

stdenv.mkDerivation {
  pname = "rmtfs";
  version = "unstable-2024-10-16";

  buildInputs = [ udev qrtr qmic ];

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "rmtfs";
    rev = "14cb1ee69f556873dc271832b77163669e1d6459";
    hash = lib.fakeHash;
  };

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "Qualcomm Remote Filesystem Service";
    homepage = "https://github.com/linux-msm/rmtfs";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
