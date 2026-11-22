{ pkgs, lib, ... }:

{
  programs.prismlauncher = {
    enable = true;
    package = pkgs.prismlauncher.override {
      jdks = with pkgs; [ graalvmPackages.graalvm-ce jdk8 ];
    };
    settings = {
      MaxMemAlloc = 4096;
      MinMemAlloc = 4096;
      Language = "fr";
      IconTheme = "pe_colored";
      JvmArgs = lib.strings.join " " [
        "-XX:+AlwaysPreTouch" "-XX:+UseShenandoahGC" "-XX:ShenandoahGCMode=generational"
        "-XX:+UnlockExperimentalVMOptions" "-XX:+DisableExplicitGC" "-XX:AllocatePrefetchStyle=1" "-XX:ShenandoahGuaranteedGCInterval=1000000"
        "-XX:+UseTransparentHugePages" "-Xss4M"
      ];

      IgnoreJavaCompatibility = true;
      IgnoreJavaWizard = true;
      AutomaticJavaDownload = false;
      AutomaticJavaSwitch = false;
      UserAskedAboutAutomaticJavaDownload = true;
      LowMemWarning = false;
      UseDiscreteGpu = true;
    };
  };
}