{ lib, config, pkgs, ... }@inputs: {
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
  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    #TODO: write this in config
    #config.pipewire-pulse = {
    #"stream.properties" = {
    #"node.latency" = "32/48000";
    #"resample.quality" = 1;
    #};
    #};
  };
  environment.systemPackages = with pkgs; [
    pulseaudio
    easyeffects
    qpwgraph
    carla
    pavucontrol
  ];
}
