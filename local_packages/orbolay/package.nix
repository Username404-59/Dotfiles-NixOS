{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  makeWrapper,
  libGL,
  fontconfig,
  freetype,
  libx11, wayland,
  libxkbcommon,
  libxtst, libxi, libxcb, libxext, libxcursor,
  libevdev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname   = "orbolay";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "SpikeHD";
    repo  = "Orbolay";
    tag   = "v${finalAttrs.version}";
    hash  = "sha256-ZyuFa/GeH5QmONuiqeSrM/st30+gaLV0mzgSCsHrU/k=";
  };

  cargoHash = "sha256-MiwAPSPnugjZnLQBVh3/iJr6Ze28jcldfMITT43iszY=";

  strictDeps = true;
  __structuredAttrs = true;

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libGL
    fontconfig
    freetype
    libx11 wayland
    libxkbcommon
    libxtst libxi libxcb libxext libxcursor
    libevdev
  ];

  # Fixes xkbcommon-dl not finding libxkbcommon, and empties WAYLAND_DISPLAY to use Xwayland
  postInstall = ''
    wrapProgram $out/bin/orbolay \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        libxkbcommon
      ]}" \
      --set WAYLAND_DISPLAY ""
  '';

  env = {
    SKIA_BINARIES_URL = "file://${fetchurl {
      url  = "https://github.com/marc2332/rust-skia/releases/download/0.98.0/skia-binaries-a9bd25883c31d7ac2b2b-x86_64-unknown-linux-gnu-egl-gl-jpegd-jpege-svg-textlayout-vulkan-wayland-webpd-webpe-x11.tar.gz";
      hash = "sha256-0ZHblarMr0gUfMa0ScDS32+CwzKk7/o7NniH9tWYvYs=";
    }}";
  };

  meta = with lib; {
    description  = "Quick, small, native, multi-platform Discord overlay alternative";
    homepage     = "https://github.com/SpikeHD/Orbolay";
    license      = licenses.gpl3Only;
    platforms    = lib.platforms.linux;
    mainProgram  = "orbolay";
    maintainers  = with lib.maintainers; [ Username404-59 ];
  };
})