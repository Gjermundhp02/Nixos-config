{
  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, android-nixpkgs }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };

    in
    with pkgs;
    {
      devShells = {
      default = pkgs.mkShell rec {
          buildInputs = [
            
          ];
        };
      };
    }
  );
}