{ mobile-nixos
, fetchFromGitHub
, fetchFromGitLab
, lib
, stdenv
, ...
}:

let
  # Use the PostmarketOS kernel config for sc7280 as the base, with
  # modifications for Mobile NixOS compatibility.
  pmaportsSrc = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "305cddc07f3739747f0662c824e4febccf0e1e28";
    hash = "sha256-QInrf7Sf9j+bB26bsC1hYOnWPz/n5K3WlC50cq7megQ=";
  };

  configfile = stdenv.mkDerivation {
    name = "fairphone-fp5-kernel-config";
    src = "${pmaportsSrc}/device/testing/linux-postmarketos-qcom-sc7280/config-postmarketos-qcom-sc7280.aarch64";
    dontUnpack = true;
    buildPhase = ''
      sed \
        -e 's/# CONFIG_DMIID is not set/CONFIG_DMIID=y/' \
        -e 's/# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set/CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m/' \
        -e 's/# CONFIG_NETFILTER_XT_MATCH_LIMIT is not set/CONFIG_NETFILTER_XT_MATCH_LIMIT=m/' \
        -e 's/# CONFIG_NETFILTER_XT_MATCH_RECENT is not set/CONFIG_NETFILTER_XT_MATCH_RECENT=m/' \
        -e 's/# CONFIG_NETFILTER_XT_MATCH_STATE is not set/CONFIG_NETFILTER_XT_MATCH_STATE=m/' \
        -e 's/# CONFIG_NETFILTER_XT_TARGET_LOG is not set/CONFIG_NETFILTER_XT_TARGET_LOG=m/' \
        -e 's/# CONFIG_TYPEC_DP_ALTMODE is not set/CONFIG_TYPEC_DP_ALTMODE=y/' \
        $src > config
    '';
    installPhase = ''
      cp config $out
    '';
  };
in

#
# sc7280-mainline kernel for the Fairphone 5 (QCM6490).
# Uses the community sc7280-mainline fork which has additional QCM6490 patches
# beyond vanilla mainline. Config is based on the PostmarketOS sc7280 config
# with modifications for NixOS/Mobile NixOS compatibility.
#
mobile-nixos.kernel-builder {
  version = "6.17.0";
  inherit configfile;

  src = fetchFromGitHub {
    owner = "sc7280-mainline";
    repo = "linux";
    rev = "v6.17.0-sc7280";
    hash = "sha256-k6Fp5Dhy1s7Jnpc1qywHZxmkH2+OAYk1Yy8vSBSyR5k=";
  };

  patches = [
    # Bluetooth H4 recv corruption fix (backport from mainline, remove when
    # sc7280-mainline updates to v6.18+)
    ./patches/fix-h4-recv-corruption.patch
    # HCI QCA: drop unused event during BT baudrate change on WCN6750/6855/7850
    ./patches/hci-qca-drop-unused-event.patch
  ];

  isModular = true;
  isCompressed = "gz";
}
