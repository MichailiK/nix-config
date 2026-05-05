{
  pkgs,
  lib,
  ...
}: let
  # "Pattern" in the attrset type refer to strings that are valid url patterns:
  # https://chromeenterprise.google/policies/url-patterns/
  #
  # Attrset:
  # - origin (optional String): Origin URL. if any attrset below is set to `true`,
  #   it will use the value of the origin
  #
  # - allowCookies (optional Bool | Pattern | List of Pattern, default true):
  #   The URL patterns allowed to store cookies & site data.
  #
  # - allowNotifications (optional Bool | Pattern | List of Pattern, default true):
  #   The URL patterns allowed to use notifications
  #
  # - restoreOnStartup (optional Bool | String, default false):
  #   The URL to open this tab on start of Chromium
  #
  # - protocolHandlers (Protocol Handler | List of Protocol Handler):
  #   List of protocol handlers to register to Chromium. Check docs for how to define a handler:
  #   https://chromeenterprise.google/policies/#RegisteredProtocolHandlers
  origins = [
    {
      origin = "https://music.youtube.com";
      allowCookies = "https://[*.]youtube.com";
      restoreOnStartup = true;
    }

    {
      origin = "https://mail.proton.me";
      restoreOnStartup = "https://mail.proton.me/u/0";
      allowCookies = "https://[*.]proton.me";
      allowNotifications = true;
      protocolHandlers = {
        "default" = true;
        "protocol" = "mailto";
        "url" = "https://mail.proton.me/inbox/#mailto=%s";
      };
    }

    {
      origin = "https://mail.google.com";
      restoreOnStartup = "https://mail.google.com/mail/u/0/";
      allowCookies = "https://[*.]google.com";
      allowNotifications = true;
      protocolHandlers = {
        "protocol" = "mailto";
        "url" = "https://mail.google.com/mail/?extsrc=mailto&url=%s";
      };
    }

    {
      origin = "https://discord.com";
      restoreOnStartup = "https://discord.com/app";
      allowNotifications = true;
    }

    {
      origin = "https://irc.michai.li";
      restoreOnStartup = true;
      allowNotifications = true;
      protocolHandlers = [
        {
          "default" = true;
          "protocol" = "irc";
          "url" = "https://irc.michai.li/?open=%s";
        }
        {
          "default" = true;
          "protocol" = "ircs";
          "url" = "https://irc.michai.li/?open=%s";
        }
      ];
    }

    {
      origin = "https://app.element.io";
      restoreOnStartup = "https://app.element.io/#/home";
      allowNotifications = true;
    }

    {
      origin = "https://web.fluxer.app";
      restoreOnStartup = true;
      allowNotifications = true;
    }

    {
      origin = "https://steamcommunity.com";
      allowCookies = [
        "https://steamcommunity.com"
        "https://[*.]steampowered.com"
        "https://steam.tv"
      ];
      restoreOnStartup = "https://steamcommunity.com/chat";
      allowNotifications = true;
    }

    {
      origin = "https://web.whatsapp.com";
      restoreOnStartup = true;
      allowNotifications = true;
    }

    {
      origin = "https://web.telegram.org";
      restoreOnStartup = true;
      allowNotifications = true;
    }

    {
      origin = "https://x.com";
      restoreOnStartup = true;
      allowNotifications = true;
    }

    {
      origin = "https://mastodon.social";
      restoreOnStartup = true;
      allowNotifications = true;
    }

    {
      origin = "https://bsky.app";
      restoreOnStartup = true;
    }

    {
      origin = "https://dash.bunny.net";
      restoreOnStartup = true;
      allowCookies = "https://[*.]bunny.net";
    }

    # Allow Kagi to store cookies
    {allowCookies = "https://[*.]kagi.com";}
    # Allow other pages to store cookies
    {allowCookies = "https://[*.]spotify.com";}
    {allowCookies = "https://[*.]paypal.com";}
    {allowCookies = "https://[*.]github.com";}
  ];
in {
  environment.systemPackages = [
    (pkgs.chromium.override {
      commandLineArgs = [
        # https://crbug.com/475549558
        "--disable-features=WaylandWpColorManagerV1"
      ];
    })
  ];

  programs.chromium = {
    enable = true;
    # TODO kinda sucks to make these system-wide
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://kagi.com/search?q={searchTerms}";
    defaultSearchProviderSuggestURL = "https://kagisuggest.com/api/autosuggest?q={searchTerms}";
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBOL
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # SteamDB
      "oboonakemofpalcgghocfoadofidjkkk" # KeePassXC-Browser
    ];
    extraOpts = {
      "DefaultCookiesSetting" = 4; # Keep cookies/site data for the duration of the session
      "CookiesAllowedForUrls" = lib.pipe origins [
        (builtins.filter (origin: origin.allowCookies or true != false))
        (builtins.map (origin:
          if (origin.allowCookies or true == true)
          then origin.origin or (builtins.throw "origin has allowCookies set to true, but no origin is defined")
          else origin.allowCookies))
        lib.flatten
      ];
      "PasswordManagerEnabled" = false;
      "RestoreOnStartup" = 4;
      "RestoreOnStartupURLs" = lib.pipe origins [
        (builtins.filter (origin: origin.restoreOnStartup or false != false))
        (builtins.map (origin:
          if (origin.restoreOnStartup == true)
          then origin.origin or (builtins.throw "origin has restoreOnStartup set to true, but no origin is defined")
          else origin.restoreOnStartup))
      ];
      "DefaultNotificationsSetting" = 2;
      "NotificationsAllowedForUrls" = lib.pipe origins [
        (builtins.filter (origin: origin.allowNotifications or false != false))
        (builtins.map (origin:
          if (origin.allowNotifications == true)
          then origin.origin or (builtins.throw "origin has allowNotifications set to true, but no origin is defined")
          else origin.allowNotifications))
        lib.flatten
      ];
      "HttpsOnlyMode" = "force_enabled";
      "DnsOverHttpsMode" = "automatic"; # Use DoH with fallback to insecure/system DNS
      "DeveloperToolsAvailability" = 1; # Allow usage of the Developer Tools, even of extensions installed using enterprise policy
      "ForcedLanguages" = ["en-US" "de-DE"];
      "HideWebStoreIcon" = true; # Do not show the Chrome Web Store icon on the new tab page
      #"IntensiveWakeUpThrottlingEnabled" = false; # Discord keeps disconnecting from Gateway presumably because of the wake up throttling
      "HighEfficiencyModeEnabled" = false; # Memory Saver in performance settings?
      "MemorySaverModeSavings" = 0; # Memory Saver will get moderate memory savings. Tabs become inactive after a longer period of time
      "MetricsReportingEnabled" = false; # anonymous reporting is disabled and no usage or crash data is sent to Google.
      "PromotionsEnabled" = false;
      "ShowFullUrlsInAddressBar" = false;
      "SiteSearchSettings" = [
        {
          "name" = "Google";
          "shortcut" = "google";
          "url" = "https://www.google.com/search?q={searchTerms}";
        }
        {
          "name" = "Kagi";
          "shortcut" = "kagi";
          "url" = "https://kagi.com/search?q={searchTerms}";
        }
        {
          "name" = "DuckDuckGo";
          "shortcut" = "duckduckgo";
          "url" = "https://duckduckgo.com/?q={searchTerms}";
        }
        {
          "name" = "GitHub";
          "shortcut" = "github";
          "url" = "https://github.com/search?q={searchTerms}";
        }
      ];
    };
  };

  environment.etc."chromium/policies/recommended/default.json" = let
    handlers = lib.pipe origins [
      (builtins.map (origin: origin.protocolHandlers or []))
      lib.flatten
    ];
  in
    lib.mkIf (builtins.length handlers != 0) {
      text = builtins.toJSON {
        RegisteredProtocolHandlers = handlers;
      };
    };
}
