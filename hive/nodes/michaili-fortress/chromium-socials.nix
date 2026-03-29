{
  pkgs,
  lib,
  ...
}: let
  # origins in this list are implicitly allowed to store cookies/data
  # (unless `allowCookies = false`).
  origins = [
    {
      origin = "https://music.youtube.com";
      restoreOnStartup = true;
    }
    {
      origin = "https://mail.proton.me";
      restoreOnStartup = "https://mail.proton.me/u/0";
      allowNotifications = true;
      protocolHandlers = [
        {
          "default" = true;
          "protocol" = "mailto";
          "url" = "https://mail.proton.me/inbox/#mailto=%s";
        }
      ];
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
    {origin = "https://kagi.com";}
    {origin = "https://youtube.com";}
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
        (builtins.filter (origin: origin.allowCookies or true == true))
        (builtins.map (origin: origin.origin))
      ];
      "PasswordManagerEnabled" = false;
      "RestoreOnStartup" = true;
      "RestoreOnStartupURLs" = lib.pipe origins [
        (builtins.filter (origin: origin.restoreOnStartup or false != false))
        (builtins.map (origin:
          if (origin.restoreOnStartup == true)
          then origin.origin
          else origin.restoreOnStartup))
      ];
      "DefaultNotificationsSetting" = 2;
      "NotificationsAllowedForUrls" = lib.pipe origins [
        (builtins.filter (origin: origin.allowNotifications or false == true))
        (builtins.map (origin: origin.origin))
      ];
      "RegisteredProtocolHandlers" = lib.pipe origins [
        (builtins.map (origin: origin.protocolHandlers or []))
        builtins.concatLists
      ];
      "HttpsOnlyMode" = "force_enabled";
      "DnsOverHttpsMode" = "automatic"; # Use DoH with fallback to insecure/system DNS
      "DeveloperToolsAvailability" = "1"; # Allow usage of the Developer Tools, even of extensions installed using enterprise policy
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
          "url" = "https://www.google.com/search?q=%s";
        }
        {
          "name" = "Kagi";
          "shortcut" = "kagi";
          "url" = "https://kagi.com/search?q=%s";
        }
        {
          "name" = "DuckDuckGo";
          "shortcut" = "duckduckgo";
          "url" = "https://duckduckgo.com/?q=%s";
        }
        {
          "name" = "GitHub";
          "shortcut" = "github";
          "url" = "https://github.com/search?q=%s";
        }
      ];
    };
  };
}
