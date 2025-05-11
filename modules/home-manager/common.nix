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
}: let 
  discordPatcher = pkgs.writers.writePython3Bin "discord-krisp-patcher" {
    libraries = with pkgs.python3Packages; [
      pyelftools
      capstone
    ];
    flakeIgnore = [
      "E265" # from nix-shell shebang
      "E501" # line too long (82 > 79 characters)
      "F403" # ‘from module import *’ used; unable to detect undefined names
      "F405" # name may be undefined, or defined from star imports: module
    ];
  } (builtins.readFile ./discord-krisp-patcher.py);
in {
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
      gcc
      libgcc
    ];
    activation.krispPatch = config.lib.dag.entryAfter ["writeBoundary"] ''
      run ${pkgs.findutils}/bin/find -L ${config.home.homeDirectory}/.config/discord -name 'discord_krisp.node' -exec ${discordPatcher}/bin/discord-krisp-patcher {} \;
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
  };

  programs = {
    git = {
      enable = true;
      userName = "gjermundhp02";
      userEmail = "gjermund.pedersen@gmail.com";
      extraConfig = {
        pull.rebase = false;
        url = {
          "ssh://git@gitlab.login.no" = {
            insteadOf = "https://gitlab.login.no";
          };
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
        rebuild = "sudo nixos-rebuild switch --flake ~/Nixos-config/#";
        testbuild = "sudo nixos-rebuild test --flake ~/Nixos-config/#";
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
  };


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
}
