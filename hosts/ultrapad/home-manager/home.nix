# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
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
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ../../../modules/home-manager/common.nix
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      barrier
      discord
      obsidian
      prusa-slicer
      lm_sensors
      stremio
      brave
      vscode
      kubernetes-helm
      inputs.openconnect-sso.packages.${pkgs.system}.default
      spotify
      k9s
      postman
      zoom-us
      vlc
    ];
  };

  programs = {
    firefox = {
      enable = true;
      #profiles.gjermund = {
      #  settings = {
      #    "full-screen-api.transition-duration.enter" = 0;
      #    "full-screen-api.transition-duration.leave" = 0;
      #    "full-screen-api.warning.timeout" = 0;
      #    "signon.rememberSignons" = false;
      #  };
      #};
    };
  };

  services = {
    remmina = {
      enable = true;
    };
  };

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
