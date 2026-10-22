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
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "brenton-keller";
    repo = "murale";
    rev = "55a3fe451b6d840b34cb6a02d9ce8979f8ca613c";
    hash = "sha256-fMLlxMpBhf7qQ+9BckPXOBKF8oiq+Rcsjbs5nhJMjdg=";
  };

  cargoHash = "sha256-KiMZ2UN9WebhITyfdUYnANy8G2hVtulrh6CbOQ5gfKA=";

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
