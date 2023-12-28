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
    })
    (lib.mkIf cfg.desktop.enable {
      environment.systemPackages = with pkgs; [
        pulseaudio
        easyeffects
        qpwgraph
        carla
        pavucontrol
      ];
    })
  ];
}
