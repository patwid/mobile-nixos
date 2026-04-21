{ lib
, fetchFromGitHub
, runCommand
}:

let
  src = fetchFromGitHub {
    owner = "FairBlobs";
    repo = "FP5-firmware";
    rev = "a4908f548e6f88965e78b1478af1751b6a854fc9";
    hash = lib.fakeHash;
  };
in
runCommand "fairphone-fp5-firmware" {
  meta.license = lib.licenses.unfreeRedistributable;
} ''
  fwdir=$out/lib/firmware

  # GPU (Adreno 643 / a660)
  mkdir -p $fwdir/qcom/qcm6490
  cp ${src}/a660_zap.mbn $fwdir/qcom/qcm6490/

  # Audio DSP
  for f in ${src}/adsp*; do
    cp $f $fwdir/qcom/qcm6490/
  done

  # Compute DSP
  for f in ${src}/cdsp*; do
    cp $f $fwdir/qcom/qcm6490/
  done

  # Modem
  for f in ${src}/modem*; do
    cp $f $fwdir/qcom/qcm6490/
  done

  # WiFi Processor Subsystem
  for f in ${src}/wpss*; do
    cp $f $fwdir/qcom/qcm6490/
  done

  # IPA (Internet Protocol Accelerator)
  for f in ${src}/yupik_ipa_fws*; do
    cp $f $fwdir/qcom/qcm6490/
  done

  # VPU
  cp ${src}/vpu20_1v.mbn $fwdir/qcom/qcm6490/

  # Battery manager
  cp ${src}/battmgr.jsn $fwdir/qcom/qcm6490/

  # Bluetooth
  mkdir -p $fwdir/qca
  cp ${src}/msbtfw11.mbn $fwdir/qca/
  cp ${src}/msnv11.bin $fwdir/qca/

  # Audio amplifier
  mkdir -p $fwdir
  cp ${src}/aw882xx_acf.bin $fwdir/

  # Hexagon filesystem
  mkdir -p $fwdir/qcom/qcm6490/hexagonfs
  cp -r ${src}/hexagonfs/* $fwdir/qcom/qcm6490/hexagonfs/

  # Modem PR (provisioning)
  mkdir -p $fwdir/qcom/qcm6490/modem_pr
  cp -r ${src}/modem_pr/* $fwdir/qcom/qcm6490/modem_pr/
''
