{ config, lib, pkgs, ... }:

let
  cfg = config.mobile.quirks.bootmac;
  inherit (lib) mkIf mkOption mkEnableOption types;
in
{
  options.mobile = {
    quirks.bootmac.enable = mkEnableOption ''
      bootmac, which assigns deterministic MAC addresses at boot
      for devices with non-persistent Wi-Fi and Bluetooth MACs
    '';

    quirks.bootmac.bluetooth = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.mobile.quirks.bootmac.enable";
        description = ''
          Whether to assign a deterministic Bluetooth MAC address at boot.
        '';
      };
      interface = mkOption {
        type = types.str;
        default = "hci0";
        description = ''
          Bluetooth interface name.
        '';
      };
    };

    quirks.bootmac.wifi = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.mobile.quirks.bootmac.enable";
        description = ''
          Whether to assign a deterministic Wi-Fi MAC address at boot.
        '';
      };
      interface = mkOption {
        type = types.str;
        default = "wlan0";
        description = ''
          Wi-Fi interface name.
        '';
      };
    };

    quirks.bootmac.macPrefix = mkOption {
      type = types.strMatching "[0-9a-fA-F]{4}";
      default = "0200";
      description = ''
        Hex prefix (4 chars) for the generated MAC address.
        Must use the locally administered bit (e.g. "0200") to avoid
        collisions with IEEE-assigned OUIs.
      '';
    };

    quirks.bootmac.timeout = mkOption {
      type = types.ints.positive;
      default = 5;
      description = ''
        Timeout in seconds for waiting on the interface.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      bootmac-bluetooth = mkIf cfg.bluetooth.enable {
        description = "Assign deterministic Bluetooth MAC address";
        wantedBy = [ "multi-user.target" ];
        before = [ "bluetooth.service" ];
        after = [ "sys-subsystem-bluetooth-devices-${cfg.bluetooth.interface}.device" ];
        requires = [ "sys-subsystem-bluetooth-devices-${cfg.bluetooth.interface}.device" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.bootmac}/bin/bootmac --bluetooth-if ${lib.escapeShellArg cfg.bluetooth.interface} --prefix ${lib.escapeShellArg cfg.macPrefix}";
        };
        environment = {
          BT_TIMEOUT = toString cfg.timeout;
        };
      };

      bootmac-wifi = mkIf cfg.wifi.enable {
        description = "Assign deterministic Wi-Fi MAC address";
        wantedBy = [ "multi-user.target" ];
        before = [ "network-pre.target" ];
        after = [ "sys-subsystem-net-devices-${cfg.wifi.interface}.device" ];
        requires = [ "sys-subsystem-net-devices-${cfg.wifi.interface}.device" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.bootmac}/bin/bootmac --wlan-if ${lib.escapeShellArg cfg.wifi.interface} --prefix ${lib.escapeShellArg cfg.macPrefix}";
        };
        environment = {
          WLAN_TIMEOUT = toString cfg.timeout;
        };
      };
    };
  };
}
