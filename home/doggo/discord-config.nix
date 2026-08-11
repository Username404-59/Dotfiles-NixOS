{ nixtamal, isLaptop, functions, pkgs, ... }:

let
  nixcord = import nixtamal.nixcord { nixpkgs = nixtamal.nixpkgs; };
in
{
  imports = [ nixcord.homeModules.nixcord ];

  programs.nixcord = {
    enable = true;
    discord = {
      package = functions.wrapWithNoPreload nixcord.packages.discord true;
      branches = [ "stable" ];
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
        questify = {
          enable = true;
          allowChangingDangerousSettings = true;
          autoCompleteQuestsSimultaneously = false;
          resumeInterruptedQuests = true;
          makeMobileVideoQuestsDesktopCompatible = true;
          completeVideoQuestsQuicker = false;

          autoCompleteQuestTypes = {
            PLAY_ON_DESKTOP = true;
            PLAY_ON_XBOX = false;
            PLAY_ON_PLAYSTATION = false;
            PLAY_ACTIVITY = true;
            WATCH_VIDEO = true;
            WATCH_VIDEO_ON_MOBILE = true;
            ACHIEVEMENT_IN_ACTIVITY = true;
          };

          disableMembersListPromo = true;
          disableFriendsListPromo = true;
          disableRelocationNotices = true;
          disableAccountPanelPromo = true;

          # https://github.com/Equicord/Equicord/blob/94c0ac8e16b293e1fb715eac3aedabe2bb96fead/src/equicordplugins/questify/settings/notices.tsx#L31
          acknowledgedNotices = {
            "quest-ban-warning-2026-08-07" = true;
          };
        };
        dragFavoriteEmotes.enable = true;
        downloadAllAttachments.enable = true;
        fullVcpfp.enable = true;
        gitHubRepos.enable = true;
        homeTyping.enable = true;
        noPushToTalk.enable = true;
        volumeBooster.enable = true;
        voiceRejoin.enable = true;
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
        biggerStreamPreview.enable = true;
        typingIndicator.enable = true; typingTweaks.enable = true;
        unitConverter = {
          enable = true;
          myUnits = "metric";
        };
        whosWatching.enable = true;
        relationshipNotifier.enable = true;
        notificationTitle.enable = true;
        voiceMessages.enable = true;
        messageLogger = { # Needed by enhanced plugin
          enable = true;
          collapseDeleted = true;
          ignoreBots = true;
          ignoreSelf = true;
        };
        messageLoggerEnhanced.enable = true;
        blurNsfw.enable = true;
        petpet.enable = true;
        alwaysAnimate.enable = !isLaptop;
        betterActivities.enable = true;
        normalizeMessageLinks.enable = true;
        validUser.enable = true;
        validReply.enable = true;
      };
    };
  };
}
