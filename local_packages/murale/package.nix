{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  mpv,
  wayland,
  libxkbcommon,
  libglvnd,
}:

rustPlatform.buildRustPackage {
  pname = "murale";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "brenton-keller";
    repo = "murale";
    tag = "published/20260830T135919";
    hash = "sha256-l4PWMWnmA0PM6qrT8bbVtENq1ivz2Qs24W5OSAKh81M=";
  };

  cargoHash = "sha256-i5DMAUfgDnrQSPNwTwToseNHu0iFHObvaZ6Fn++fTS4=";

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    mpv
    wayland
    libxkbcommon
    libglvnd
  ];

  meta = {
    description = "Lean, memory-safe video wallpaper player for Wayland compositors";
    homepage    = "https://github.com/brenton-keller/murale";
    license     = lib.licenses.mit;
    platforms   = lib.platforms.linux;
    mainProgram = "murale";
    maintainers = with lib.maintainers; [ Username404-59 ];
  };
}
