{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-stremio.url = "github:nixos/nixpkgs/25845a52fee515073b0bcf8503ed0f2f78ce89a5";

    # asus-numberpad-driver = {
    #   url = "github:asus-linux-drivers/asus-numberpad-driver";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    vscode-server,
    # asus-numberpad-driver,
    ...
  } @ inputs: let
    inherit (self) outputs;

    username = "gjermund";
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = let
      wsl = "wsl";
      workstation = "workstation";
      ultrapad = "ultrapad";
    in {
      ${ultrapad} = let
        hostname = ultrapad;
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs username hostname;};
          modules = [
            ./hosts/ultrapad/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./hosts/ultrapad/home-manager/home.nix;

              home-manager.extraSpecialArgs = {
                inherit inputs outputs username hostname;
              };
            }
            # asus-numberpad-driver.nixosModules.default
          ];
        };
      ${workstation} = let
        hostname = workstation;
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs username hostname;};
          modules = [
            ./hosts/workstation/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./hosts/workstation/home-manager/home.nix;

              home-manager.extraSpecialArgs = {
                inherit inputs outputs username hostname;
              };
            }
          ];
        };
      ${wsl} = let
        hostname = wsl;
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs username hostname;};
          system = "x86_64-linux";
          modules = [
            ./hosts/wsl/nixos/configuration.nix
            vscode-server.nixosModules.default
            ({...}: {
              services.vscode-server.enable = true;
            })
            nixos-wsl.nixosModules.default
            {
              system.stateVersion = "24.05";
              wsl.enable = true;
              wsl.defaultUser = username;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./hosts/wsl/home-manager/home.nix;

              home-manager.extraSpecialArgs = {
                inherit inputs outputs username hostname;
              };
            }
          ];
        };
    };
  };
}
