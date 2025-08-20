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
        isDarwin = pkgs.stdenv.isDarwin;
        };
        pinnedJDK = pkgs.jdk17;
        buildToolsVersion = "36.0.0";
        ndkVersion = "26.1.10909125";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "19.0"; # CLI tools
          toolsVersion = "26.1.1"; # Legacy tools
          platformToolsVersion = "36.0.0"; # Platform tools
          buildToolsVersions = [ buildToolsVersion "35.0.0" "34.0.0" ];
          includeEmulator = false;
          emulatorVersion = "30.3.4";
          # Target Android version
          platformVersions = [ "35" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          cmakeVersions = [ "3.10.2" "3.22.1" ];
          includeNDK = true;
          ndkVersion = ndkVersion;
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

            # Made it so that ANDROID_NDK_HOME was ignored
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";

            shellHook = ''
              alias easd="eas build --local -p android --profile preview"
              alias cda="cd .."
              echo "Android development environment ready"
              '';
          };
          admin-api = pkgs.mkShell {
            hardeningDisable = [ "fortify" ];
            buildInputs = [
              go
              redis
              gnumake
              delve
            ];
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
