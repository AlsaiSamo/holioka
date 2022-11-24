{lib, pkgs, ...}:

{
    security.rtkit.enable = true;
    security.pam.loginLimits = [
    {domain = "@audio"; type = "-"; item = "rtprio"; value = "98";}
    {domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited";}
    {domain = "@audio"; type = "-"; item = "nice"; value = "-11";}
    ];

    boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
    environment.systemPackages = with pkgs; [
        pulseaudio
            helvum
            easyeffects
            qpwgraph
#        libcamera
            carla
            pavucontrol
    ];

#TODO low latency config
#prio 6 scale big
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        config.pipewire-pulse = {
            "stream.properties" = {
                    "node.latency" = "32/48000";
                    "resample.quality" = 1;
                };
        };
    };
}
