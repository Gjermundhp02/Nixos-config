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
    ../../../home-manager/home.nix
  ];

  home = {
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
    ];
  };

  programs = {
    firefox = {
      enable = true;
      profiles.gjermund = {
        settings = {
          "full-screen-api.transition-duration.enter" = 0;
          "full-screen-api.transition-duration.leave" = 0;
          "full-screen-api.warning.timeout" = 0;
          "signon.rememberSignons" = false;
        };
      };
    };
    k9s = {
      enable = true;
    };
  };

  services = {
    remmina = {
      enable = true;
    };
  };
}
