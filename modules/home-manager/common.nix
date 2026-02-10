# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  config,
  pkgs,
  username,
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
      nh
      signal-desktop
      calibre
      solaar
      libreoffice
      kubectl
      k9s
      prismlauncher
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
      settings.user = {
        name = "gjermundhp02";
        email = "gjermund.pedersen@gmail.com";
      };
      signing = {
        format = "ssh";
        signByDefault = true;
        key = "~/.ssh/id_ed25519.pub";
      };
    };
    ssh = {
      enable = true;
    };
    bash = {
      enable = true;
      historyControl = ["ignoredups"];
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        l = "ls";
      };
      initExtra = ''
        mkcd() {
          mkdir -p "$1"
          cd "$1"
        }
      '';
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
