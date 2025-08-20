{...}: {
  mich.meta = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDOyut24Su2VhiwLRBKs4JEw1AUSJeOFb20lQzFS7IY"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOfIZqoC4EDFc3f035ss7L9C0jJrADRXyf/akwm+g29+fY31xbamftCFjbBGhzGtaa0YdxQrLT3mg75QOawQK6qMRnu0yCO5SXK2pIRzi8niC5c3PE4e7SN/yAp7p8CqQoH1zZY1+wU4pvqg8UsJcms8xuLiIaSwgVV3i/uuj93AeCCVu6UQTPV0VoLNd2G3AaNd5i0CgRynGS/t0/xuc9vqQLejNzUT+III4G3FRl6yOPMI3l5hSeon1BNxh+c7eSVuRd4t+7HDFjJrPGb4a6ew7WmuSTPJKlfcJWDg7ww5vwxco3ujz9kC5Ba2ugB5o80zYxVNhkrRLYjj5/k70IuWHb20H9eouO5LMBi6dZLDK51EGsjWvDwLYuvDJQB7XqBqIC8BB0qDq8Zy3DDtz4A5NHqhioIfolzo2ukH4PRHxHqDiZ0JQ0Im9mvNLu2ajN+p01vN9Nm48dX2JhEtAi6zw8n4um+iyiAI2MK972c63TmahrzKR3ANyxM8cRQpDY1SCloUFKy21n6Ode7fQI8B6bwS58Sf+GcNo3qCRdCqTZH5+fOdWp1F5VKUFgOmKLrB3feYAGHSyhVT7krf0fMHKOW/jXDNMkpWCnsy4mSfhk1B5cgzFbTHd7QJqpzpmWOn721xiXfv4bn3BxiBPDb77DfuszumlqU2Y08puqKw=="
      ];
    };
  };

  networking.hostName = "raptor";
  networking.domain = "michai.li";
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "24.11";
}
