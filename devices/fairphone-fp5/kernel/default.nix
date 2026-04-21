{ mobile-nixos
, fetchFromGitHub
, lib
, ...
}:

#
# Mainline Linux kernel for the Fairphone 5 (QCM6490).
# The FP5 device tree has been upstream since Linux 6.7.
# postmarketOS also uses mainline for this device.
#
# The kernel config needs to be generated and normalized:
#   $ bin/menuconfig fairphone-fp5
#   $ bin/kernel-normalize-config fairphone-fp5
#
mobile-nixos.kernel-builder {
  version = "6.12.6";
  configfile = ./config.aarch64;

  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    rev = "v6.12.6";
    # TODO: replace with actual hash after first build attempt
    hash = lib.fakeHash;
  };

  isModular = true;
}
