{
  description = "Android development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
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

        pinnedJDK = pkgs.jdk17;
        buildToolsVersion = "35.0.0";
        ndkVersion = "26.1.10909125";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "35.0.2";
          buildToolsVersions = [ buildToolsVersion "34.0.0" ];
          includeEmulator = false;
          emulatorVersion = "30.3.4";
          platformVersions = [ "35" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          cmakeVersions = [ "3.10.2" "3.22.1" ];
          includeNDK = true;
          ndkVersions = [ ndkVersion ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
          includeExtras = [
            "extras;google;gcm"
          ];
        };

        sdk = androidComposition.androidsdk;
      in
      with pkgs;
      {
        devShells = {
          # Define the Android devShell
          android = mkShell rec {
            buildInputs = [
              pinnedJDK
              sdk
              pkg-config
              pkgs.nodePackages.eas-cli
              pkgs.nodejs_22
              pkgs.ffmpeg
            ];

            JAVA_HOME = pinnedJDK;
            ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
            ANDROID_NDK_HOME = "${ANDROID_SDK_ROOT}/ndk/${ndkVersion}";

            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";

            shellHook = ''
              alias easd="eas build --local -p android --profile preview"
              alias cda="cd .."
              echo "Android development environment ready"
              '';
          };
          js = pkgs.mkShell rec {
            buildInputs = [
              pkgs.nodejs_22
            ];
          };
          python = pkgs.mkShell rec {
            buildInputs = [
              pkgs.python312
              pkgs.uv
            ];
          };
          dotnet = pkgs.mkShell rec {
            buildInputs = [
              pkgs.dotnetCorePackages.dotnet_9.sdk
              pkgs.vscode-fhs
            ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          };
          PROG2005 = pkgs.mkShell rec {
            buildInputs = [
              pkgs.go
              pkgs.delve
              pkgs.google-cloud-sdk
              pkgs.zulu8
            ];
          };
          PROG2006 = pkgs.mkShell rec {
            buildInputs = with pkgs; [
              cargo
              rustc
              haskellPackages.ghc
              haskellPackages.ghci
              haskellPackages.cabal-install
              haskellPackages.haskell-language-server
              haskellPackages.doctest
              pkgs.haskellPackages.prelude-compat
              stack
              xorg.libX11
              xorg.libXcursor
              xorg.libXrandr
              xorg.libXi
            ];

            RUST_BACKTRACE = "1";
            LD_LIBRARY_PATH = "${pkgs.xorg.libXi}/lib:${pkgs.xorg.libXrandr}/lib:${pkgs.xorg.libXcursor}/lib:${pkgs.xorg.libX11}/lib";

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          };
          IDATG2204 = pkgs.mkShell rec {
            buildInputs = [
              pkgs.php
              pkgs.mariadb
              pkgs.apacheHttpd
              pkgs.perl
            ];
          };
          DSCG2003 = pkgs.mkShell rec {
            buildInputs = [
              pkgs.terraform
            ];
          };
          admin-api = pkgs.mkShell rec {
            hardeningDisable = [ "fortify" ];
            buildInputs = [
              go
              redis
              gnumake
              delve
            ];
          };
          cam-control = pkgs.mkShell rec {
            buildInputs = [
              pinnedJDK
              sdk
              pkg-config
              pkgs.nodePackages.eas-cli
              pkgs.nodejs_22
              pkgs.cargo
              pkgs.rustc
            ];
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            JAVA_HOME = pinnedJDK;
            ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
            ANDROID_NDK_HOME = "${ANDROID_SDK_ROOT}/ndk/${ndkVersion}";

            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";
          };
          camControl = mkShell rec {
            buildInputs = [
              pinnedJDK
              sdk
              pkg-config
              pkgs.nodePackages.eas-cli
              pkgs.nodejs_22
              pkgs.ffmpeg
              pkgs.rustc
              pkgs.cargo
            ];

            JAVA_HOME = pinnedJDK;
            ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
            ANDROID_NDK_HOME = "${ANDROID_SDK_ROOT}/ndk/${ndkVersion}";

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";

            shellHook = ''
              alias easd="eas build --local -p android --profile preview"
              alias cda="cd .."
              echo "Android development environment ready"
              '';
          };
        };
      }
    );
}
