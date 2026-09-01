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
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "brenton-keller";
    repo = "murale";
    tag = "published/20260831T221415";
    hash = "sha256-73xzxWSbvEIWLuvBqX0Zh1QECNoF+Za2Cu92pGCF5aw=";
  };

  cargoHash = "sha256-hAt25aOuQTMCBqBo/Jh0ssnhZe/KJOiqMOSFrAXH0nI=";

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
