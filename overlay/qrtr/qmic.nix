{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "qmic";
  version = "unstable-2024-07-22";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "qmic";
    rev = "4574736afce75aa5eec1e1069a19563410167c9f";
    hash = lib.fakeHash;
  };

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "QMI IDL compiler";
    homepage = "https://github.com/linux-msm/qmic";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
