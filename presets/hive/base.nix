{
  lib,
  config,
  ...
}: {
  imports = [../base.nix];
  mich.hive.defaultUser = {
    name = "michaili";
    description = "Michail K";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOct0GpSUGR8eFXiyPF6rHFQ9r97rdH/+rv/GDZnSyqS openpgp:0x5E718B7B"
    ];
    hashedPasswordFile = let
      filePath = config.mich.hive.secrets.paths."hive-user-default-password" or null;
    in
      lib.mkIf (filePath != null) filePath;
  };

  # non-hive SSH servers I have access to
  mich.ssh.hosts = {
    "nectarine.whatbox.ca" = {
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN53CQPYz1vCd++lWDxwtrP42pL5nNAragYL2aBqMB2H"
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACBzFwIxrfnYQeCYlgCQpZ9tkKuM9zDMgbHhO6YKuz703xA7oEb2ES5zETGXxULun9mjw8xDk+GW0t81QAeOX7/uQEQ9dQCV9Agk3xVOWRImvNV4GLeDRuTlmbLrlPp4Mz07Q734i3PJs5dPjjeRroVqGTKhDrzask1XrkcodcIuYNkEA=="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuRk30XTpE8XSXMO3U9v1ErEftXyePAVIVw2XC4rQK/J5pi/xLpjlQVwpEfI7Nfgtggbu47JGk+oou2WmEZP6b+YqTwWlT65S0BITeeneH8bDsG057RqMLwr98kPnt1R7Jc7urIvBUPy605tvhxc5bVCaiC5ulje9l8+FV0gtUu1EKb5pGufuy6Tn7nKs2sRvpfJjUgrj+nLyFm1OZAvCmTPSXjJJvq7Qqyg4OljPOTBdz6QPAMhFXcgAy8yb8cZ4BqhhZqoDAKCcFFDvWooHTXXlPC+xNN2sLNl1/rizFJ+WInwgwot4VY6wH8jJ1wY2oHO2ddnXt/8rg/pLDoQy5"
      ];
      extraConfig.User = "michailik";
    };
    "eris.whatbox.ca" = {
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDj4nzQCi3x06rxe7whNPh5bo5pAhhSJiONIlrNMPF9"
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAvFV3Oj30P0oExrzB87imf79lu8jUXQunagu/VgeEJ494NXz+eFrM9rV2Dg+jcyYcNoCU0NUlBwQBJxvyxUkn23wB51FatZ1ZvL06bJ7xNJzReWiBwMxv+Vi1SL6vzpJgu4WwAWjGk2mWs4VcWEkYYImzy1BSgNE18qC8zMom8XbTa9Q=="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBGBipovBxJb3BmAJJXLquDFyA1mqcXAe5YWl7xt7FgGp2acZnux0qXN81uviSKPec2l1k5J16Okpj/pT6zW5XPyIF1X6/cET8MzBmzbQemcrXbX7e891C+UXJc3WJmC6QlYOo49hgjBCcQPu8IANv2hUhFs5MIRvywMU5ektDMcxP1+NUo8pvQoW1JaSy1gaUufq3ZN+yyzYF3eOWv8SL3gP9DuX1RRe7dsrUGjvR832V+C54trI898KbzVqLm1lQg9QfEyDUE1mIzF7NHCw4hIBGBV84cJQSIQzZ7mKcXY+Db7MDPuidZF7zQS768Shie+865ttCvFve7vQsfXLT"
      ];
      extraConfig.User = "michailik";
    };
  };
}
