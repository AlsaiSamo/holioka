{
  lib,
  config,
  pkgs,
  ...
}@inputs:
let
  cfg = config.hlk.audio;
in
#TODO: review
{
  options = {
    hlk.audio.default.enable = lib.mkEnableOption "default audio configuration";
    hlk.audio.desktop.enable = lib.mkEnableOption "desktop audio applications";
    hlk.audio.lowLatency.enable = lib.mkEnableOption "low latency PW configuration";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.default.enable {
      security.rtkit.enable = true;
      security.pam.loginLimits = [
        {
          domain = "@audio";
          type = "-";
          item = "rtprio";
          value = "98";
        }
        {
          domain = "@audio";
          type = "-";
          item = "memlock";
          value = "unlimited";
        }
        {
          domain = "@audio";
          type = "-";
          item = "nice";
          value = "-11";
        }
      ];
      boot.kernelModules = [
        "snd-seq"
        "snd-rawmidi"
      ];
      security.polkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      #TODO: doesn't load the module
      # programs.noisetorch.enable = true;
    })
    (lib.mkIf cfg.desktop.enable {
      environment.systemPackages = with pkgs; [
        qpwgraph
        # carla

        pulseaudio
        pavucontrol
      ];
    })
    (lib.mkIf cfg.lowLatency.enable {
      #This does not work?
      services.pipewire.configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/92-low-latency.conf" ''
          context.properties = {
            default.clock.power-of-two-quantum = true
            default.clock.rate = 48000
            default.clock.quantum = 128
            default.clock.min-quantum = 128
            default.clock.max-quantum = 512
          }
        '')
        (pkgs.writeTextDir "share/pipewire/pipewire-pulse.conf.d/92-low-latency.conf" ''
          stream.properties = {
            node.latency = 128/48000
          }
          pulse.properties = {
            pulse.min.req = 128/48000
            pulse.default.req = 128/48000
            pulse.min.frag = 128/48000
            # pulse.default.frag = 48000
            # pulse.default.tlength = 48000
            pulse.min.quantum = 128/48000
          }
        '')
        (pkgs.writeTextDir "share/pipewire/pipewire-client.conf.d/92-low-latency.conf" ''
          stream.properties = {
            node.latency = 128/48000
          }
        '')
        (pkgs.writeTextDir "share/pipewire/pipewire-jack.conf.d/92-low-latency.conf" ''
          stream.properties = {
            node.latency = 128/48000
          }
        '')
      ];
    })
  ];
}
