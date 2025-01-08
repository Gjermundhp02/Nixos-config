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
  # You can import other home-manager modules here
  imports = [
    ../../../home-manager/home.nix
  ];

  home = {
    packages = with pkgs; [
      wget
    ];
  };
}