# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  pkgs,
  username,
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
      android-tools
      jetbrains.idea-ultimate
      android-studio
      discord
      obsidian
      prusa-slicer
      lm_sensors
      stremio
      brave
      vscode
      kubernetes-helm
      spotify
      gnomeExtensions.dash-to-panel
      postman
      zoom-us
      vlc
    ];
  };

  programs = {
    firefox = {
      enable = true;
    };
  };

  services = {
    remmina = {
      enable = true;
    };
  };
  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
