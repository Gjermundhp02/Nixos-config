{
  description = "All my shells";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        pinnedJDK = pkgs.jdk17;
        buildToolsVersion = "36.0.0";
        ndkVersion = "27.1.12297006";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "19.0"; # CLI tools
          toolsVersion = "26.1.1"; # Legacy tools
          platformToolsVersion = "36.0.0"; # Platform tools
          buildToolsVersions = [buildToolsVersion "35.0.0" "34.0.0"];
          includeEmulator = true;
          emulatorVersion = "36.1.2";
          # Target Android version
          platformVersions = ["36"];
          includeSources = false;
          includeSystemImages = true;
          systemImageTypes = ["google_apis_playstore"];
          abiVersions = ["x86_64" "arm64-v8a"];
          cmakeVersions = ["3.10.2" "3.22.1"];
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
        with pkgs; {
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
                pkgs.ungoogled-chromium
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
          };
        }
    );
}
