{ pkgs, lib, ... }:

{
  programs.prismlauncher = {
    enable = true;
    package = with pkgs; (prismlauncher.override {
      jdks = [
        graalvmPackages.graalvm-ce
        jdk25
        jdk21
      ];
    });
    settings = {
      MaxMemAlloc = 4096;
      MinMemAlloc = 4096;
      Language = "fr";
      IconTheme = "pe_colored";
      JvmArgs = lib.strings.join " " [
        "-XX:+AlwaysPreTouch" "-XX:+UseShenandoahGC" "-XX:ShenandoahGCMode=generational"
        "-XX:+UnlockExperimentalVMOptions" "-XX:+DisableExplicitGC" "-XX:AllocatePrefetchStyle=1" "-XX:ShenandoahGuaranteedGCInterval=1000000"
        "XX:+UseTransparentHugePages" "-Xss4M"
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