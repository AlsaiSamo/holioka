{
  lib,
  config,
  pkgs,
  ...
} @ inputs: let
  cfg = config.hlk.audio;
in {
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
      boot.kernelModules = ["snd-seq" "snd-rawmidi"];
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      programs.noisetorch.enable = true;
    })
    (lib.mkIf cfg.desktop.enable {
      environment.systemPackages = with pkgs; [
        easyeffects
        qpwgraph
        helvum
        carla

        pulseaudio
        pavucontrol
      ];
    })
    (lib.mkIf cfg.lowLatency.enable {
      #TODO: this has to be configurable per-machine (specifically quantums)
      #TODO: pulseaudio and devices
      #NOTE: json.generate might be generating incorrect things for this?
      #encasing everything in ""
      environment.etc = {
        "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
          clock.power-of-two-quantum = true
          context.properties = {
            default.clock.rate = 48000
            default.clock.quantum = 128
            default.clock.min-quantum = 32
            default.clock.max-quantum = 256
          }
          # Attempt to configure pulse
          # stream.properties = {
          #   node.latency = 256/48000
          # }
          # context.modules = [
          #   { name = libpipewire-module-protocol-pulse
          #     args = { }
          #   }
          # ]
          #       pulse.properties = {
          #         pulse.min.req = 32/48000
          #         pulse.default.req = 128/48000
          #         pulse.max.req = 256/48000
          #         pulse.min.quantum = 32/48000
          #         pulse.max.quantum = 256/48000
          #       }
        '';
        # "pipewire/pipewire-pulse.conf.d/92-low-latency.conf".text = ''
        #   context.properties = {
        #   }
        # '';
        # "pipewire/pipewire-pulse.conf.d/92-low-latency.conf".text = ''
        #   stream.properties = {
        #     node.latency = 256/48000
        #   }
        #   context.modules = [
        #     { name = libpipewire-module-protocol-pulse
        #       args = {
        #         pulse.min.req = 32/48000
        #         pulse.default.req = 128/48000
        #         pulse.max.req = 256/48000
        #         pulse.min.quantum = 32/48000
        #         pulse.max.quantum = 256/48000
        #       }
        #     }
        #   ]
        # '';
      };
    })
  ];
}
