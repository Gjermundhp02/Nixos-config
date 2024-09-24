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
    # ./nvim.nix
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      barrier
      vscode
      discord
      obsidian
      prusa-slicer
      gcc
      libgcc
      lm_sensors
      stremio
      brave
    ];
  };

  programs = {
    git = {
      enable = true;
      userName = "gjermundhp02";
      userEmail = "gjermund.pedersen@gmail.com";
      extraConfig = {
        pull.rebase = false;
      };
    };
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
    ssh = {
      enable = true;
      matchBlocks = {
          "skyhigh" = {
              hostname = "10.212.170.43";
              user = "ubuntu";
          };
          "server" = {
              user = "gjermund";
              hostname = "128.39.140.146";
              port = 420;
          };
      };
    };
    bash = {
      enable = true;
      historyControl = ["ignoredups"];
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        l = "ls";
        rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles/#";
        buildtest = "sudo nixos-rebuild test --flake ~/dotfiles/#";
        mkcd = "mkdir -p $1 && cd $1";
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      config = {
        whitelist = {
          prefix = ["/home/gjermund/Documents/Login/nucleus"];
        };
        nix-direnv.enable = true;
      };
    };
    k9s = {
      enable = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
