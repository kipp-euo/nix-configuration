{ ... }:
{
    programs.vesktop.vencord.settings.plugins = {
        "ChatInputButtonAPI" = {
            "enabled" = true;
        };
        "CommandsAPI" = {
            "enabled" = true;
        };
        "DynamicImageModalAPI" = {
            "enabled" = true;
        };
        "MemberListDecoratorsAPI" = {
            "enabled" = true;
        };
        "MessageAccessoriesAPI" = {
            "enabled" = true;
        };
        "MessageDecorationsAPI" = {
            "enabled" = true;
        };
        "MessageEventsAPI" = {
            "enabled" = true;
        };
        "MessagePopoverAPI" = {
            "enabled" = true;
        };
        "MessageUpdaterAPI" = {
            "enabled" = true;
        };
        "UserSettingsAPI" = {
            "enabled" = true;
        };
        "AlwaysAnimate" = {
            "enabled" = true;
        };
        "BetterGifPicker" = {
            "enabled" = true;
        };
        "BetterSettings" = {
            "enabled" = true;
            "disableFade" = true;
            "eagerLoad" = true;
        };
        "CallTimer" = {
            "enabled" = true;
            "format" = "stopwatch";
        };
        "CharacterCounter" = {
            "enabled" = true;
            "colorEffects" = true;
        };
        "ClearURLs" = {
            "enabled" = true;
        };
        "CopyFileContents" = {
            "enabled" = true;
        };
        "CrashHandler" = {
            "enabled" = true;
        };
        "DisableCallIdle" = {
            "enabled" = true;
        };
        "DontRoundMyTimestamps" = {
            "enabled" = true;
        };
        "ExpressionCloner" = {
            "enabled" = true;
        };
        "FakeNitro" = {
            "enabled" = true;
            "enableStickerBypass" = true;
            "enableStreamQualityBypass" = true;
            "enableEmojiBypass" = true;
            "transformEmojis" = true;
            "transformStickers" = true;
            "transformCompoundSentence" = false;
            "emojiSize" = 64;
            "stickerSize" = 256;
            "useHyperLinks" = true;
            "hyperLinkText" = "{{NAME}}";
            "disableEmbedPermissionCheck" = false;
            "isFavorite" = true;
        };
        "FixImagesQuality" = {
            "enabled" = true;
            "originalImagesInChat" = false;
        };
        "ForceOwnerCrown" = {
            "enabled" = true;
        };
        "FullSearchContext" = {
            "enabled" = true;
        };
        "FullUserInChatbox" = {
            "enabled" = true;
        };
        "GifPaste" = {
            "enabled" = true;
        };
        "ImageFilename" = {
            "enabled" = true;
        };
        "ImageZoom" = {
            "enabled" = true;
            "size" = 218.87890786596537;
            "zoom" = 6.399999999999999;
            "nearestNeighbour" = false;
            "square" = false;
            "invertScroll" = true;
            "zoomSpeed" = 0.5;
            "saveZoomValues" = true;
        };
        "MemberCount" = {
            "enabled" = true;
            "memberList" = true;
            "toolTip" = true;
            "voiceActivity" = true;
        };
        "MentionAvatars" = {
            "enabled" = true;
            "showAtSymbol" = true;
        };
        "MessageClickActions" = {
            "enabled" = true;
            "requireModifier" = false;
            "enableDoubleClickToReply" = true;
            "enableDoubleClickToEdit" = true;
        };
        "MessageLatency" = {
            "enabled" = true;
            "latency" = 2;
            "detectDiscordKotlin" = true;
            "showMillis" = false;
            "ignoreSelf" = false;
        };
        "MessageLinkEmbeds" = {
            "enabled" = true;
            "listMode" = "blacklist";
            "idList" = "";
            "automodEmbeds" = "never";
        };
        "MessageLogger" = {
            "enabled" = true;
            "deleteStyle" = "text";
            "logDeletes" = true;
            "collapseDeleted" = false;
            "logEdits" = true;
            "inlineEdits" = true;
            "ignoreBots" = false;
            "ignoreSelf" = false;
            "ignoreUsers" = "";
            "ignoreChannels" = "";
            "ignoreGuilds" = "";
            "logDeletedAttachments" = true;
        };
        "MoreQuickReactions" = {
            "enabled" = true;
            "reactionCount" = 5;
        };
        "MutualGroupDMs" = {
            "enabled" = true;
        };
        "NoMiddleClickPaste" = {
            "enabled" = true;
        };
        "NoTypingAnimation" = {
            "enabled" = true;
        };
        "PictureInPicture" = {
            "enabled" = true;
        };
        "PlatformIndicators" = {
            "enabled" = true;
            "list" = true;
            "badges" = true;
            "messages" = true;
            "colorMobileIndicator" = true;
        };
        "QuickMention" = {
            "enabled" = true;
        };
        "ReverseImageSearch" = {
            "enabled" = true;
        };
        "Summaries" = {
            "enabled" = true;
            "summaryExpiryThresholdDays" = 30;
        };
        "ServerInfo" = {
            "enabled" = true;
        };
        "ShowHiddenChannels" = {
            "enabled" = true;
            "showMode" = 0;
            "hideUnreads" = true;
            "defaultAllowedUsersAndRolesDropdownState" = true;
        };
        "ShowHiddenThings" = {
            "enabled" = true;
            "showTimeouts" = true;
            "showInvitesPaused" = true;
            "showModView" = true;
        };
        "SilentTyping" = {
            "enabled" = true;
            "isEnabled" = true;
            "showIcon" = false;
        };
        "StickerPaste" = {
            "enabled" = true;
        };
        "SuperReactionTweaks" = {
            "enabled" = true;
            "superReactByDefault" = true;
            "unlimitedSuperReactionPlaying" = false;
            "superReactionPlayingLimit" = 20;
        };
        "TypingTweaks" = {
            "enabled" = true;
            "alternativeFormatting" = true;
            "showRoleColors" = true;
            "showAvatars" = true;
        };
        "UserMessagesPronouns" = {
            "enabled" = true;
            "showSelf" = true;
            "pronounsFormat" = "LOWERCASE";
        };
        "ViewIcons" = {
            "enabled" = true;
            "format" = "webp";
            "imgSize" = "1024";
        };
        "ViewRaw" = {
            "enabled" = true;
            "clickMethod" = "Left";
            "messageContextMenu" = false;
        };
        "VoiceDownload" = {
            "enabled" = true;
        };
        "VoiceMessages" = {
            "enabled" = true;
            "noiseSuppression" = true;
            "echoCancellation" = true;
        };
        "VolumeBooster" = {
            "enabled" = true;
            "multiplier" = 2;
        };
        "WebKeybinds" = {
            "enabled" = true;
            "showNavigationButtons" = true;
            "overrideCommonKeybinds" = true;
        };
        "WebScreenShareFixes" = {
            "enabled" = true;
        };
        "WhoReacted" = {
            "enabled" = true;
            "clickableAvatars" = true;
        };
        "BadgeAPI" = {
            "enabled" = true;
        };
        "NoTrack" = {
            "enabled" = true;
            "disableAnalytics" = true;
        };
        "Settings" = {
            "enabled" = true;
            "settingsLocation" = "aboveNitro";
            "includeVencordInfoWhenCopying" = true;
        };
        "ConcatenatedComponentExtractor" = {
            "enabled" = true;
        };
        "ContextMenuAPI" = {
            "enabled" = true;
        };
        "DisableDeepLinks" = {
            "enabled" = true;
        };
        "NoticesAPI" = {
            "enabled" = true;
        };
        "SupportHelper" = {
            "enabled" = true;
        };
        "WebContextMenus" = {
            "enabled" = true;
        };
        "AddAttachments" = {
            "enabled" = true;
        };
        "GifProviderSwitcher" = {
            "enabled" = true;
            "provider" = "tenor";
        };
        "FixDiscordCss" = {
            "enabled" = true;
        };
        "DirectFileDownload" = {
            "enabled" = true;
        };
      };
}
