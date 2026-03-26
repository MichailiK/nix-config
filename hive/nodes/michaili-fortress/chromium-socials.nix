{pkgs, ...}: {
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
      "PasswordManagerEnabled" = false;
    };
  };
}
