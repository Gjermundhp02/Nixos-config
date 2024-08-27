# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    nodePackages.eas-cli = prev.nodePackages.eas-cli.overrideAttrs (oldAttrs: rec {
      version = "10.2.4";
      src = builtins.fetchurl {
        url = "https://registry.npmjs.org/eas-cli/-/eas-cli-${version}.tgz";
        sha256 = "0yrd1zapz48njhga6a6sqq90fhqs4c4kigiiqv6s73mp4r00ir6q";
        };
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
