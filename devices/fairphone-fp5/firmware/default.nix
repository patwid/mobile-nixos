{ lib
, fetchFromGitHub
, pil-squasher
, findutils
, stdenv
}:

stdenv.mkDerivation {
  pname = "fairphone-fp5-firmware";
  version = "unstable-2026-01-09";

  src = fetchFromGitHub {
    owner = "FairBlobs";
    repo = "FP5-firmware";
    rev = "a4908f548e6f88965e78b1478af1751b6a854fc9";
    hash = lib.fakeHash;
  };

  meta.license = lib.licenses.unfreeRedistributable;

  nativeBuildInputs = [ pil-squasher findutils ];

  buildPhase = ''
    runHook preBuild

    # Convert split Qualcomm firmware (.mdt + .bXX) to monolithic .mbn format
    # that the mainline Linux kernel expects.
    find . -name "*.mdt" -type f | while read -r mdtfile; do
      echo "Squashing: $mdtfile"
      pil-squasher "''${mdtfile%.mdt}.mbn" "$mdtfile"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    fwdir=$out/lib/firmware

    # GPU, DSP, modem, WiFi firmware — path must match the kernel DTS
    mkdir -p $fwdir/qcom/qcm6490/fairphone5
    install -Dm644 -t $fwdir/qcom/qcm6490/fairphone5 \
      a660_zap.mbn \
      adsp.mbn \
      cdsp.mbn \
      modem.mbn \
      wpss.mbn

    # JSON config files
    install -Dm644 -t $fwdir/qcom/qcm6490/fairphone5 \
      adspr.jsn \
      adsps.jsn \
      adspua.jsn \
      battmgr.jsn \
      cdspr.jsn \
      modemr.jsn

    # IPA firmware (renamed for kernel compatibility)
    install -Dm644 yupik_ipa_fws.mbn \
      $fwdir/qcom/qcm6490/fairphone5/ipa_fws.mbn

    # Venus video firmware (renamed for kernel compatibility)
    install -Dm644 vpu20_1v.mbn \
      $fwdir/qcom/qcm6490/fairphone5/venus.mbn

    # Bluetooth firmware
    mkdir -p $fwdir/qca
    install -Dm644 -t $fwdir/qca \
      msbtfw11.mbn \
      msnv11.bin

    # Audio amplifier firmware
    install -Dm644 aw882xx_acf.bin $fwdir/aw882xx_acf.bin

    # Modem provisioning data
    cp -r modem_pr $fwdir/qcom/qcm6490/fairphone5/
    find $fwdir/qcom/qcm6490/fairphone5/modem_pr -type f -exec chmod 0644 {} \;

    # HexagonFS (sensors and socinfo)
    mkdir -p $out/usr/share/qcom/qcm6490/Fairphone/fp5
    cp -r hexagonfs/sensors $out/usr/share/qcom/qcm6490/Fairphone/fp5/
    cp -r hexagonfs/socinfo $out/usr/share/qcom/qcm6490/Fairphone/fp5/
    find $out/usr/share/qcom/qcm6490/Fairphone/fp5 -type f -exec chmod 0644 {} \;

    runHook postInstall
  '';
}
