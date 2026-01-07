# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  pkgs,
  username,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    ../../../modules/nixos/common.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-vaapi-driver ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment = {
    systemPackages = with pkgs; [
      pinentry-all
      # OBS shit
      vpl-gpu-rt         # oneVPL runtime for Arc/Xe/Meteor Lake
      ffmpeg-full              # includes oneVPL/QSV replacements
    ];
  };
  services.dbus.packages = [ pkgs.gcr ];
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  fileSystems."/shared" = {
    # TODO: Change to exFAT
    device = "/dev/nvme0n1p5";
    options = ["nofail" "users" "exec"];
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [pkgs.networkmanager-openconnect];

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  hardware.enableAllFirmware = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # OBS shit
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver      # new Intel iHD VAAPI driver (required)
    ];
  };

  # Enable KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  security = {
    # If enabled, pam_wallet will attempt to automatically unlock the user’s default KDE wallet upon login.
    # If the user has no wallet named “kdewallet”, or the login password does not match their wallet password,
    # KDE will prompt separately after login.
    pam = {
      services = {
        ${username} = {
          kwallet = {
            enable = true;
            package = pkgs.kdePackages.kwallet-pam;
          };
        };
      };
    };
  };

  
  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };

  # services.asus-numberpad-driver = {
  #   enable = true;
  #   layout = "up5401ea";
  #   wayland = true;
  #   config = {
  #     "activation_time" = "0.5";
  #     # More Configuration Options
  #   };
  # };

  # Configure console keymap
  console.keyMap = "no";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Might not need this
  services.openssh.enable = false;

  users.users = {
    ${username} = {
      extraGroups = ["networkmanager" "docker"];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
