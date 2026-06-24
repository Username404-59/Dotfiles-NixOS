{
  lib,
  fetchFromGitHub,
  cmake,
  vulkan-headers,
  llvmPackages,
  qt6,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk";
  version = "2.0.0-dev";

  src = fetchFromGitHub {
    owner = "PancakeTAS";
    repo = "lsfg-vk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qb3vufCzNpM1r+vgo8M9nnA7CENgGTithWG0oXqLKbI=";
  };

  nativeBuildInputs = [
    llvmPackages.clang-tools
    llvmPackages.libllvm
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    vulkan-headers
    qt6.qtbase
    qt6.qtdeclarative
  ];

  cmakeFlags = [
    "-DLSFGVK_LAYER_LIBRARY_PATH=${placeholder "out"}/lib/liblsfg-vk-layer.so"
    "-DLSFGVK_BUILD_UI=ON"
    "-DLSFGVK_INSTALL_XDG_FILES=ON"
    "-DLSFGVK_BUILD_CLI=OFF"
  ];

  meta = {
    description = "Lossless Scaling Frame Generation on Linux";
    homepage = "https://github.com/PancakeTAS/lsfg-vk/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})