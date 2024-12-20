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
      discord
      obsidian
      prusa-slicer
      gcc
      libgcc
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
          "login-1-idrac-3Y8HDD2" = {
            user = "local";
            hostname = "128.39.142.138";
            localForwards = [
              {
                bind.port = 443;
                host.address = "192.168.1.105";
                host.port = 443;
              }
            ];
            extraOptions = {
              "SessionType" = "none";
            };
          };
          "login-2-idrac-3YBGDD2" = {
            user = "local";
            hostname = "128.39.142.138";
            localForwards = [
              {
                bind.port = 443;
                host.address = "192.168.1.141";
                host.port = 443;
              }
            ];
            extraOptions = {
              "SessionType" = "none";
            };
          };
          "login-idrac-3-3LVJ3K2" = {
            user = "local";
            hostname = "128.39.142.138";
            localForwards = [
              {
                bind.port = 443;
                host.address = "192.168.1.54";
                host.port = 443;
              }
            ];
            extraOptions = {
              "SessionType" = "none";
            };
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

  services = {
    remmina = {
      enable = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
