{
  lib,
  fetchgit,
  cmake,
  vulkan-headers,
  llvmPackages,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk";
  version = "2.0.0";

  src = fetchgit {
    url = "https://git.lsfg-vk.dev/lsfg-vk.git";
    tag = finalAttrs.version;
    hash = "sha256-vp0/adJdVV73C2RFjcEE90KjWiZJQhiqqOlYQ89RG+Y=";
  };

  nativeBuildInputs = [
    llvmPackages.clang-tools
    llvmPackages.libllvm
    cmake
  ];

  buildInputs = [
    vulkan-headers
  ];

  cmakeFlags = [
    "-DLSFGVK_LAYER_LIBRARY_PATH=${placeholder "out"}/lib/liblsfg-vk-layer.so"
    "-DLSFGVK_BUILD_LAYER=ON"
    "-DLSFGVK_BUILD_UI=OFF"
    "-DLSFGVK_BUILD_CLI=OFF"
    "-DLSFGVK_MANAGED=ON"
  ];

  meta = {
    description = "Lossless Scaling Frame Generation on Linux";
    homepage = "https://github.com/PancakeTAS/lsfg-vk/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})