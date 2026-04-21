{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      fairphone-fp5-alsa-ucm = self.callPackage (
        { runCommand, fetchFromGitHub }:

        runCommand "fairphone-fp5-alsa-ucm" {
          src = fetchFromGitHub {
            name = "fairphone-fp5-alsa-ucm";
            owner = "sc7280-mainline";
            repo = "alsa-ucm-conf";
            rev = "c6fdb24805b75b47a0dc415ba199563b20fad42d"; # main
            hash = lib.fakeHash;
          };
        } ''
          mkdir -p $out/share/
          ln -s $src $out/share/alsa
        ''
      ) {};
    })
  ];

  # ALSA UCM2 profiles for speaker and microphone routing
  mobile.quirks.audio.alsa-ucm-meld = true;
  environment.systemPackages = [
    pkgs.fairphone-fp5-alsa-ucm
  ];

  # WirePlumber: force S32LE format on all ALSA sinks.
  # The q6asm-dai driver advertises S32 format; without this rule,
  # PipeWire may negotiate S16LE which won't work with the AW88261
  # amplifiers that require 32-bit samples.
  environment.etc."wireplumber/wireplumber.conf.d/52-fairphone-fp5.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          { node.name = "~alsa_output.*" }
        ]
        actions = {
          update-props = {
            audio.format = S32LE
          }
        }
      }
    ]
  '';
}
