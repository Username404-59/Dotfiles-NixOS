{
  lib,
  fetchFromGitHub,
  cmake,
  llvmPackages,
  qt6,
  lsfg-vk,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk-ui";
  version = lsfg-vk.version;

  src = lsfg-vk.src;

  nativeBuildInputs = [
    llvmPackages.clang-tools
    llvmPackages.libllvm
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];

  cmakeFlags = [
    "-DLSFGVK_BUILD_VK_LAYER=OFF"
    "-DLSFGVK_BUILD_UI=ON"
    "-DLSFGVK_INSTALL_XDG_FILES=ON"
    "-DLSFGVK_BUILD_CLI=OFF"
  ];

  meta = {
    description = "Lossless Scaling Frame Generation on Linux (UI part)";
    homepage = "https://github.com/PancakeTAS/lsfg-vk/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})