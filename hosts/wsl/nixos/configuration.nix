# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  username,
  hostname,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    ../../../nixos/configuration.nix
  ];

  networking.hostName = hostname;

  environment = {
    systemPackages = with pkgs; [
      wget
    ];
  };
}
