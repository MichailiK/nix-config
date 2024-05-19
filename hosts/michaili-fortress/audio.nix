{pkgs, ...}: {
  environment.systemPackages = [ pkgs.qpwgraph ];
  services = {
    pipewire = {
      enable = true;
      audio.enable = true;
      wireplumber.enable = true;
      pulse.enable = true;

      configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-virtual-sinks.conf" ''
          context.objects = [
              {   factory = adapter
                  args = {
                     factory.name     = support.null-audio-sink
                     node.name        = "VNode System"
                     media.class      = Audio/Sink
                     object.linger    = true
                     audio.position   = [ FL FR ]
                     monitor.channel-volumes = false
                  }
              },
              {   factory = adapter
                  args = {
                     factory.name     = support.null-audio-sink
                     node.name        = "VNode Voice"
                     media.class      = Audio/Sink
                     object.linger    = true
                     audio.position   = [ FL FR ]
                     monitor.channel-volumes = false
                  }
              },
              {   factory = adapter
                  args = {
                     factory.name     = support.null-audio-sink
                     node.name        = "VNode Applications"
                     media.class      = Audio/Sink
                     object.linger    = true
                     audio.position   = [ FL FR ]
                     monitor.channel-volumes = false
                  }
              },
              {   factory = adapter
                  args = {
                     factory.name     = support.null-audio-sink
                     node.name        = "VNode Combined"
                     media.class      = Audio/Sink
                     object.linger    = true
                     audio.position   = [ FL FR ]
                     monitor.channel-volumes = false
                  }
              }
          ]
        '')
      ];
    };
  };
}
