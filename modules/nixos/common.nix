{
  username,
  hostname,
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      # outputs.overlays.stremio
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = ["nix-command" "flakes"];
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
  hardware.logitech.wireless.enable = true;

  environment = {
    systemPackages = with pkgs; [
      home-manager
      nixd
      alejandra
    ];
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = ["en_US.UTF-8/UTF-8" "nb_NO.UTF-8/UTF-8"];
  };

  programs.steam = {
    enable = true;
  };

  networking.hostName = hostname;

  time.timeZone = "Europe/Oslo";

  users.users = {
    ${username} = let
      firstChar = lib.toUpper (builtins.substring 0 1 username);
      rest = builtins.substring 1 (builtins.stringLength username) username;
    in {
      description = firstChar + rest;
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
