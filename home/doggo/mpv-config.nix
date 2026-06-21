{ config, pkgs, nixtamal, ... }:

let
  shaders = "${pkgs.anime4k}";
in
{
  programs.mpv = {
    enable = true;

    config = {
      glsl-shaders = "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Restore_CNN_VL.glsl:${shaders}/Anime4K_Upscale_CNN_x2_VL.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl";
      vo = "gpu-next";
      gpu-context = "waylandvk";
      gpu-api = "vulkan";
      hwdec = "vulkan";
      deband = "yes";

      # Stuff needed for ModernZ
      watch-later-options-remove = "sub-pos";
    };

    package = (
      pkgs.mpv.override {
        mpv-unwrapped = (pkgs.mpv-unwrapped.override {
          ffmpeg = pkgs.ffmpeg-full;
        }).overrideAttrs (oldAttrs: {
          src = nixtamal.mpv;
        });

        scripts = with pkgs.mpvScripts; [
          modernz
        ];
      }
    );
  };

  xdg.configFile."mpv/input.conf".text = ''
    # Optimized shaders for higher-end GPU:
    CTRL+& no-osd change-list glsl-shaders set "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Restore_CNN_VL.glsl:${shaders}/Anime4K_Upscale_CNN_x2_VL.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"
    CTRL+é no-osd change-list glsl-shaders set "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Restore_CNN_Soft_VL.glsl:${shaders}/Anime4K_Upscale_CNN_x2_VL.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"
    CTRL+" no-osd change-list glsl-shaders set "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"
    CTRL+' no-osd change-list glsl-shaders set "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Restore_CNN_VL.glsl:${shaders}/Anime4K_Upscale_CNN_x2_VL.glsl:${shaders}/Anime4K_Restore_CNN_M.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"
    CTRL+( no-osd change-list glsl-shaders set "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Restore_CNN_Soft_VL.glsl:${shaders}/Anime4K_Upscale_CNN_x2_VL.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Restore_CNN_Soft_M.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"
    CTRL+- no-osd change-list glsl-shaders set "${shaders}/Anime4K_Clamp_Highlights.glsl:${shaders}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${shaders}/Anime4K_AutoDownscalePre_x2.glsl:${shaders}/Anime4K_AutoDownscalePre_x4.glsl:${shaders}/Anime4K_Restore_CNN_M.glsl:${shaders}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"
    CTRL+à no-osd change-list glsl-shaders clr ""; vf clr ""; show-text "GLSL shaders / vapoursynth cleared"
    # CTRL+k no-osd change-list vf set "vapoursynth=${config.xdg.dataHome}/mpv_x2.py"; show-text "Vapoursynth: x2 FPS (720p downscale)"
  '';
}
