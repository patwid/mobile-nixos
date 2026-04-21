{ config, lib, pkgs, ... }:

{
  mobile.device.name = "fairphone-fp5";
  mobile.device.identity = {
    name = "Fairphone 5";
    manufacturer = "Fairphone";
  };
  mobile.device.supportLevel = "best-effort";

  mobile.hardware = {
    soc = "qualcomm-qcm6490";
    ram = 1024 * 8;
    screen = {
      width = 1224;
      height = 2700;
    };
  };

  mobile.boot.stage-1 = {
    compression = "gz";
    kernel.package = pkgs.callPackage ./kernel {};
    kernel.modules = [
      # USB-C audio switch
      "fsa4480"
      # Touchscreen
      "goodix_berlin_core"
      "goodix_berlin_spi"
      # Display
      "msm"
      "panel-raydium-rm692e5"
      # USB-C redriver
      "ptn36502"
      # Qualcomm SPI controller (needed for touchscreen)
      "spi-geni-qcom"
    ];
  };

  mobile.device.firmware = pkgs.callPackage ./firmware {};

  hardware.enableRedistributableFirmware = true;

  # Qualcomm firmware must not be compressed — DSP/modem subsystems cannot
  # load compressed firmware files.
  hardware.firmwareCompression = "none";

  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  mobile.system.type = "android";
  mobile.system.android = {
    ab_partitions = true;
    device_name = "FP5";
    bootimg = {
      header_version = "2";
      # Boot header v2 embeds the DTB via --dtb rather than appending to the kernel
      dtb = let kernel = config.mobile.boot.stage-1.kernel.package;
        in "${kernel}/dtbs/qcom/qcm6490-fairphone-fp5.dtb";
      dtb_offset = "0x01f00000";
      flash = {
        offset_base = "0x00000000";
        offset_kernel = "0x00008000";
        offset_ramdisk = "0x01000000";
        offset_second = "0x00000000";
        offset_tags = "0x00000100";
        pagesize = "4096";
      };
    };
  };

  mobile.usb.mode = "gadgetfs";
  mobile.usb.idVendor = "18D1"; # Google
  mobile.usb.idProduct = "D001"; # "Nexus 4"
  mobile.usb.gadgetfs.functions = {
    adb = "ffs.adb";
    rndis = "rndis.usb0";
  };

  mobile.quirks.qualcomm.qcm6490-modem.enable = true;

  boot.kernelParams = [
    "console=ttyMSM0,115200n8"
    # Framebuffer console — boot messages visible on the phone's screen
    "console=tty1"
  ];
}
