{ nixtamal, isLaptop, ... }:

{
  imports = [ (import nixtamal.nixcord).homeModules.nixcord ];

  programs.nixcord = {
    enable = true;
    discord = {
      branch = "canary";
      openASAR.enable = true;
      equicord.enable = true;
      krisp.enable = true;
      commandLineArgs = [ ];
    };

    quickCss = builtins.readFile ./discord_css/myClearVisionV7.css;
    config = {
      useQuickCss = true;
      frameless = true;
      transparent = true;
      disableMinSize = true;

      plugins = {
        crashHandler.enable = true;
        fakeNitro.enable = true; noNitroUpsell.enable = true;
        disableCallIdle.enable = true;
        fixImagesQuality.enable = true;
        fixYoutubeEmbeds.enable = true;
        youtubeAdblock.enable = true;
        gifPaste.enable = true;
        clipUpload.enable = true;
        clipsEnhancements.enable = true;
        newPluginsManager.enable = true;
        questify.enable = false;
        dragFavoriteEmotes.enable = true;
        downloadAllAttachments.enable = true;
        fullVcpfp.enable = true;
        gitHubRepos.enable = true;
        homeTyping.enable = true;
        noPushToTalk.enable = true;
        screenRecorder.enable = true;
        showHiddenChannels.enable = true;
        streamingCodecDisabler = {
          enable = true;
          # Disable everything except av1
          disableAv1Codec = false;
          disableH265Codec = true;
          disableH264Codec = true;
          disableVp8Codec = true;
          disableVp9Codec = true;
        };
        typingIndicator.enable = true; typingTweaks.enable = true;
        unitConverter = {
          enable = true;
          myUnits = "metric";
        };
        whosWatching.enable = true;
        relationshipNotifier.enable = true;
        notificationTitle.enable = true;
        voiceMessages.enable = true;
        messageLoggerEnhanced.enable = true;
        blurNsfw.enable = true;
        petpet.enable = true;
        alwaysAnimate.enable = !isLaptop;
        betterActivities.enable = true;
        normalizeMessageLinks.enable = true;
      };
    };
  };
}
