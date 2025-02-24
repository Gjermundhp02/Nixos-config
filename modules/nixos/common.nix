{
  username,
  hostname,
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes"];
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

  environment = {
    systemPackages = with pkgs; [
      home-manager
    ];
  };

  networking.hostName = hostname;

  time.timeZone = "Europe/Oslo";

  users.users = {
    ${username} = let
      firstChar = builtins.substring 0 1 username;
      rest = builtins.substring 1 (builtins.stringLength username) username;
    in {
      description = "Gjermund";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}