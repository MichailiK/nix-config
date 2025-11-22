{pkgs, ...}: {
  services.pulseaudio.enable = false;
  environment.systemPackages = [
    pkgs.qpwgraph
    pkgs.easyeffects
  ];
  services = {
    pipewire = {
      configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-virtual-sinks.conf" ''
            context.objects = [
              {
                factory = adapter
                args = {
                  factory.name     = support.null-audio-sink
                  node.name        = "v-system"
                  node.description = "VNode System"
                  node.virtual     = true
                  node.passive     = true
                  media.class      = Audio/Sink
                  priority.session = 1000
                  object.linger    = true
                  audio.position   = [ FL FR ] # [ FL FR FC LFE RL RR ]
                  audio.channels   = 2 # https://github.com/dimtpap/obs-pipewire-audio-capture/issues/67#issuecomment-2312591100
                  monitor.channel-volumes = false
                  monitor.passthrough     = true
                }
              }
              {
                factory = adapter
                args = {
                  factory.name     = support.null-audio-sink
                  node.name        = "v-app"
                  node.description = "VNode App"
                  node.virtual     = true
                  node.passive     = true
                  media.class      = Audio/Sink
                  object.linger    = true
                  audio.position   = [ FL FR ]
                  audio.channels   = 2
                  monitor.channel-volumes = false
                  monitor.passthrough     = true
                }
              }
              {
                factory = adapter
                args = {
                  factory.name     = support.null-audio-sink
                  node.name        = "v-voice"
                  node.description = "VNode Voice"
                  node.virtual     = true
                  node.passive     = true
                  media.class      = Audio/Sink
                  object.linger    = true
                  audio.position   = [ FL FR ]
                  audio.channels   = 2
                  monitor.channel-volumes = false
                  monitor.passthrough     = true
                }
              }
          ]

        '')

        # Combines all the above virtual sinks into one "VNode Combined" node.
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/11-v-combined.conf" ''
          context.modules = [
            {
              name = libpipewire-module-combine-stream
              args = {
                combine.mode = source
                node.name = "v-combined"
                node.description = "VNode Combined"
                combine.latency-compensate = true
                combine.props = {
                  audio.position = [ FL FR ]
                  audio.channels = 2
                  node.passive = true
                }
                stream.props = {
                  node.passive = true
                }
                stream.rules = [
                  {
                    matches = [
                      { node.name = "v-system" }
                      { node.name = "v-app" }
                      { node.name = "v-voice" }
                    ]
                    actions = {
                      create-stream = {
                        stream.capture.sink = true
                      }
                    }
                  }
                ]
              }
            }
          ]

        '')

        # Takes the above "VNode Combined" node & outputs it to every ALSA output device present
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/12-v-combined-alsa-out.conf" ''
          context.modules = [
            {
              name = libpipewire-module-combine-stream
              args = {
                combine.mode = capture
                node.name = "v-combined-alsa-out"
                node.description = "VNode Combined ALSA Out"
                combine.latency-compensate = true
                combine.props = {
                  audio.position = [ FL FR ]
                  audio.channels = 2
                  node.passive = true
                  target.object = "v-combined"
                }
                stream.props = {
                  node.passive = true
                }
                stream.rules = [
                  {
                    matches = [
                      {
                        node.name = "~alsa_output.*"
                        media.class = "Audio/Sink"
                      }
                    ]
                    actions = {
                      create-stream = {}
                    }
                  }
                ]
              }
            }
          ]

        '')
      ];

      wireplumber = {
        # Broken/incomplete Lua script that would automatically link
        # specific programs to the VNode apps & voice sinks
        /*
          extraScripts = {
          "v-node-links.lua" = ''
            function createVNodeInterest (name)
              return Interest {
                type = "node",
                Constraint { "node.name", "equals", name, type = "pw-global" },
              }
            end

            local vSystemInterest = createVNodeInterest("v-system")
            local vAppInterest = createVNodeInterest("v-app")
            local vVoiceInterest = createVNodeInterest("v-voice")

            local vnode_om = ObjectManager {
              vSystemInterest,
              vAppInterest,
              vVoiceInterest,
            }

            local node_apps_om = ObjectManager {
              Interest {
                type = "node",
                Constraint { "application.name", "equals", "Looking Glass", type = "pw-global" },
                Constraint { "media.class", "equals", "Stream/Output/Audio", type = "pw-global" },
              }
            }

            node_apps_om:connect("object-added", function (om, node)

              print("Node by '" .. node.properties["application.name"] .. "' available")
            end)

            node_om:activate()
            clients_apps_om:activate()
          '';
        };
        extraConfig."10-v-node-links" = {
          "wireplumber.components" = [
            {
              name = "v-node-links.lua";
              type = "script/lua";
              provides = "custom.v-node-links";
            }
          ];

          "wireplumber.profiles" = {
            main = {
              "custom.v-node-links" = "required";
            };
          };
        };
        */
      };
    };
  };
}
