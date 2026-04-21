{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "pil-squasher";
  version = "unstable-2020-11-04";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "pil-squasher";
    rev = "3c9f8b8756ba6e4dbf9958570fd4c9aea7a70cf4";
    hash = "sha256-MEW85w3RQhY3tPaWtH7OO22VKZrjwYUWBWnF3IF4YC0=";
  };

  meta = with lib; {
    description = "Qualcomm firmware squasher — converts split .mdt format to monolithic .mbn";
    homepage = "https://github.com/linux-msm/pil-squasher";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };

  makeFlags = [ "prefix=$(out)" ];

  doInstallCheck = true;
  installCheckPhase = ''
    # pil-squasher prints usage to stderr and exits non-zero when called without args
    ($out/bin/pil-squasher 2>&1 || true) | grep -q "mbn output"
  '';
}
