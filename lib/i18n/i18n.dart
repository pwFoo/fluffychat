import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<I18n> load(Locale locale) {
    return I18n.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<I18n> old) {
    return false;
  }
}

class I18n {
  I18n(this.localeName);

  static Future<I18n> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return I18n(localeName);
    });
  }

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  final String localeName;

  /* <=============> Translations <=============> */

  String get about => Intl.message("About");

  String acceptedTheInvitation(String username) => Intl.message(
        "$username accepted the invitation",
        name: "acceptedTheInvitation",
        args: [username],
      );

  String activatedEndToEndEncryption(String username) => Intl.message(
        "$username activated end to end encryption",
        name: "activatedEndToEndEncryption",
        args: [username],
      );

  String get addGroupDescription => Intl.message("Add a group description");

  String get admin => Intl.message("Admin");

  String get alias => Intl.message("alias");

  String get alreadyHaveAnAccount => Intl.message("Already have an account?");

  String get anyoneCanJoin => Intl.message("Anyone can join");

  String get archive => Intl.message("Archive");

  String get archivedRoom => Intl.message("Archived Room");

  String get areGuestsAllowedToJoin =>
      Intl.message("Are guest users allowed to join");

  String get authentication => Intl.message("Authentication");

  String get avatarHasBeenChanged => Intl.message("Avatar has been changed");

  String get banFromChat => Intl.message("Ban from chat");

  String get banned => Intl.message("Banned");

  String bannedUser(String username, String targetName) => Intl.message(
        "$username banned $targetName",
        name: "bannedUser",
        args: [username, targetName],
      );

  String changedTheChatAvatar(String username) => Intl.message(
        "$username changed the chat avatar",
        name: "changedTheChatAvatar",
        args: [username],
      );

  String changedTheChatNameTo(String username, String chatname) => Intl.message(
        "$username changed the chat name to: '$chatname'",
        name: "changedTheChatNameTo",
        args: [username, chatname],
      );

  String changedTheChatDescriptionTo(String username, String description) =>
      Intl.message(
        "$username changed the chat description to: '$description'",
        name: "changedTheChatDescriptionTo",
        args: [username, description],
      );

  String changedTheChatPermissions(String username) => Intl.message(
        "$username changed the chat permissions",
        name: "changedTheChatPermissions",
        args: [username],
      );

  String changedTheDisplaynameTo(String username, String displayname) =>
      Intl.message(
        "$username changed the displayname to: $displayname",
        name: "changedTheDisplaynameTo",
        args: [username, displayname],
      );

  String changedTheGuestAccessRules(String username) => Intl.message(
        "$username changed the guest access rules",
        name: "changedTheGuestAccessRules",
        args: [username],
      );

  String changedTheGuestAccessRulesTo(String username, String rules) =>
      Intl.message(
        "$username changed the guest access rules to: $rules",
        name: "changedTheGuestAccessRulesTo",
        args: [username, rules],
      );

  String changedTheHistoryVisibility(String username) => Intl.message(
        "$username changed the history visibility",
        name: "changedTheHistoryVisibility",
        args: [username],
      );

  String changedTheHistoryVisibilityTo(String username, String rules) =>
      Intl.message(
        "$username changed the history visibility to: $rules",
        name: "changedTheHistoryVisibilityTo",
        args: [username, rules],
      );

  String changedTheJoinRules(String username) => Intl.message(
        "$username changed the join rules",
        name: "changedTheJoinRules",
        args: [username],
      );

  String changedTheJoinRulesTo(String username, String joinRules) =>
      Intl.message(
        "$username changed the join rules to: $joinRules",
        name: "changedTheJoinRulesTo",
        args: [username, joinRules],
      );

  String changedTheProfileAvatar(String username) => Intl.message(
        "$username changed the profile avatar",
        name: "changedTheProfileAvatar",
        args: [username],
      );

  String changedTheRoomAliases(String username) => Intl.message(
        "$username changed the room aliases",
        name: "changedTheRoomAliases",
        args: [username],
      );

  String changedTheRoomInvitationLink(String username) => Intl.message(
        "$username changed the invitation link",
        name: "changedTheRoomInvitationLink",
        args: [username],
      );

  String get changelog => Intl.message("Changelog");

  String get changeTheNameOfTheGroup =>
      Intl.message("Change the name of the group");

  String get chatDetails => Intl.message('Chat details');

  String get chooseAUsername => Intl.message("Choose a username");

  String get close => Intl.message("Close");

  String get confirm => Intl.message("Confirm");

  String get connectionAttemptFailed =>
      Intl.message("Connection attempt failed");

  String get contactHasBeenInvitedToTheGroup =>
      Intl.message("Contact has been invited to the group");

  String get contentViewer => Intl.message("Content viewer");

  String get copiedToClipboard => Intl.message("Copied to clipboard");

  String get couldNotDecryptMessage =>
      Intl.message("Could not decrypt message");

  String get couldNotSetAvatar => Intl.message("Could not set avatar");

  String get couldNotSetDisplayname =>
      Intl.message("Could not set displayname");

  String countParticipants(String count) => Intl.message(
        "$count participants",
        name: "countParticipants",
        args: [count],
      );

  String get create => Intl.message("Create");

  String get createAccountNow => Intl.message("Create account now");

  String createdTheChat(String username) => Intl.message(
        "$username created the chat",
        name: "createdTheChat",
        args: [username],
      );

  String get createNewGroup => Intl.message("Create new group");

  String dateAndTimeOfDay(String date, String timeOfDay) => Intl.message(
        "$date, $timeOfDay",
        name: "dateAndTimeOfDay",
        args: [date, timeOfDay],
      );

  String dateWithoutYear(String month, String day) => Intl.message(
        "$month-$day",
        name: "dateWithoutYear",
        args: [month, day],
      );

  String dateWithYear(String year, String month, String day) => Intl.message(
        "$year-$month-$day",
        name: "dateWithYear",
        args: [year, month, day],
      );

  String get delete => Intl.message("Delete");

  String get deleteMessage => Intl.message("Delete message");

  String get discardPicture => Intl.message("Discard picture");

  String get displaynameHasBeenChanged =>
      Intl.message("Displayname has been changed");

  String download(String fileName) => Intl.message(
        "Download $fileName",
        name: "download",
        args: [fileName],
      );

  String get editDisplayname => Intl.message("Edit displayname");

  String get emptyChat => Intl.message("Empty chat");

  String get enterAGroupName => Intl.message("Enter a group name");

  String get enterAUsername => Intl.message("Enter a username");

  String get fluffychat => Intl.message("FluffyChat");

  String get forward => Intl.message('Forward');

  String get friday => Intl.message("Friday");

  String get fromJoining => Intl.message("From joining");

  String get fromTheInvitation => Intl.message("From the invitation");

  String get group => Intl.message("Group");

  String get groupDescription => Intl.message("Group description");

  String get groupDescriptionHasBeenChanged =>
      Intl.message("Group description has been changed");

  String get groupIsPublic => Intl.message("Group is public");

  String groupWith(String displayname) => Intl.message(
        "Group with $displayname",
        name: "groupWith",
        args: [displayname],
      );

  String get guestsAreForbidden => Intl.message("Guests are forbidden");

  String get guestsCanJoin => Intl.message("Guests can join");

  String hasWithdrawnTheInvitationFor(String username, String targetName) =>
      Intl.message(
        "$username has withdrawn the invitation for $targetName",
        name: "hasWithdrawnTheInvitationFor",
        args: [username, targetName],
      );

  String get help => Intl.message("Help");

  String get homeserverIsNotCompatible =>
      Intl.message("Homeserver is not compatible");

  String get inviteContact => Intl.message("Invite contact");

  String inviteContactToGroup(String groupName) => Intl.message(
        "Invite contact to $groupName",
        name: "inviteContactToGroup",
        args: [groupName],
      );

  String get invited => Intl.message("Invited");

  String invitedUser(String username, String targetName) => Intl.message(
        "$username invited $targetName",
        name: "invitedUser",
        args: [username, targetName],
      );

  String get invitedUsersOnly => Intl.message("Invited users only");

  String get isTyping => Intl.message("is typing...");

  String joinedTheChat(String username) => Intl.message(
        "$username joined the chat",
        name: "joinedTheChat",
        args: [username],
      );

  String kicked(String username, String targetName) => Intl.message(
        "$username kicked $targetName",
        name: "kicked",
        args: [username, targetName],
      );

  String kickedAndBanned(String username, String targetName) => Intl.message(
        "$username kicked and banned $targetName",
        name: "kickedAndBanned",
        args: [username, targetName],
      );

  String get kickFromChat => Intl.message("Kick from chat");

  String get leave => Intl.message('Leave');

  String get leftTheChat => Intl.message("Left the chat");

  String get logout => Intl.message("Logout");

  String userLeftTheChat(String username) => Intl.message(
        "$username left the chat",
        name: "userLeftTheChat",
        args: [username],
      );

  String get license => Intl.message("License");

  String get loadingPleaseWait => Intl.message("Loading... Please wait");

  String loadCountMoreParticipants(String count) => Intl.message(
        "Load $count more participants",
        name: "loadCountMoreParticipants",
        args: [count],
      );

  String get login => Intl.message("Login");

  String get makeAnAdmin => Intl.message("Make an admin");

  String get makeSureTheIdentifierIsValid =>
      Intl.message("Make sure the identifier is valid");

  String get messageWillBeRemovedWarning =>
      Intl.message("Message will be removed for all participants");

  String get moderator => Intl.message("Moderator");

  String get monday => Intl.message("Monday");

  String get muteChat => Intl.message('Mute chat');

  String get newMessageInFluffyChat =>
      Intl.message('New message in FluffyChat');

  String get newPrivateChat => Intl.message("New private chat");

  String get noGoogleServicesWarning => Intl.message(
      "It seems that you have no google services on your phone. That's a good decision for your privacy! To receive push notifications in FluffyChat we recommend using microG: https://microg.org/");

  String get noRoomsFound => Intl.message("No rooms found...");

  String get notSupportedInWeb => Intl.message("Not supported in web");

  String get oopsSomethingWentWrong =>
      Intl.message("Oops something went wrong...");

  String get openCamera => Intl.message('Open camera');

  String get optionalGroupName => Intl.message("(Optional) Group name");

  String get password => Intl.message("Password");

  String play(String fileName) => Intl.message(
        "Play $fileName",
        name: "play",
        args: [fileName],
      );

  String get pleaseChooseAUsername => Intl.message("Please choose a username");

  String get pleaseEnterAMatrixIdentifier =>
      Intl.message('Please enter a matrix identifier');

  String get pleaseEnterYourPassword =>
      Intl.message("Please enter your password");

  String get pleaseEnterYourUsername =>
      Intl.message("Please enter your username");

  String get rejoin => Intl.message("Rejoin");

  String redactedAnEvent(String username) => Intl.message(
        "$username redacted an event",
        name: "redactedAnEvent",
        args: [username],
      );

  String rejectedTheInvitation(String username) => Intl.message(
        "$username rejected the invitation",
        name: "rejectedTheInvitation",
        args: [username],
      );

  String removedBy(String username) => Intl.message(
        "Removed by $username",
        name: "removedBy",
        args: [username],
      );

  String get removeExile => Intl.message("Remove exile");

  String get revokeAllPermissions => Intl.message("Revoke all permissions");

  String get remove => Intl.message("Remove");

  String get removeMessage => Intl.message('Remove message');

  String get saturday => Intl.message("Saturday");

  String get share => Intl.message("Share");

  String sharedTheLocation(String username) => Intl.message(
        "$username shared the location",
        name: "sharedTheLocation",
        args: [username],
      );

  String get searchForAChat => Intl.message("Search for a chat");

  String get secureYourAccountWithAPassword =>
      Intl.message("Secure your account with a password");

  String seenByUser(String username) => Intl.message(
        "Seen by $username",
        name: "seenByUser",
        args: [username],
      );

  String seenByUserAndUser(String username, String username2) => Intl.message(
        "Seen by $username and $username2",
        name: "seenByUserAndUser",
        args: [username, username2],
      );

  String seenByUserAndCountOthers(String username, String count) =>
      Intl.message(
        "Seen by $username and $count others",
        name: "seenByUserAndCountOthers",
        args: [username, count],
      );

  String get sendAMessage => Intl.message("Send a message");

  String get sendFile => Intl.message('Send file');

  String get sendImage => Intl.message('Send image');

  String sentAFile(String username) => Intl.message(
        "$username sent a file",
        name: "sentAFile",
        args: [username],
      );

  String sentAnAudio(String username) => Intl.message(
        "$username sent an audio",
        name: "sentAnAudio",
        args: [username],
      );

  String sentAPicture(String username) => Intl.message(
        "$username sent a picture",
        name: "sentAPicture",
        args: [username],
      );

  String sentASticker(String username) => Intl.message(
        "$username sent a sticker",
        name: "sentASticker",
        args: [username],
      );

  String sentAVideo(String username) => Intl.message(
        "$username sent a video",
        name: "sentAVideo",
        args: [username],
      );

  String get setAProfilePicture => Intl.message("Set a profile picture");

  String get setGroupDescription => Intl.message("Set group description");

  String get setInvitationLink => Intl.message("Set invitation link");

  String get settings => Intl.message("Settings");

  String get signUp => Intl.message("Sign up");

  String get sourceCode => Intl.message("Source code");

  String get startYourFirstChat => Intl.message("Start your first chat :-)");

  String get sunday => Intl.message("Sunday");

  String get donate => Intl.message("Donate");

  String get tapToShowMenu => Intl.message("Tap to show menu");

  String get thisRoomHasBeenArchived =>
      Intl.message("This room has been archived.");

  String get thursday => Intl.message("Thursday");

  String timeOfDay(
          String hours12, String hours24, String minutes, String suffix) =>
      Intl.message(
        "$hours12:$minutes $suffix",
        name: "timeOfDay",
        args: [hours12, hours24, minutes, suffix],
      );

  String get title => Intl.message(
        'FluffyChat',
        name: 'title',
        desc: 'Title for the application',
        locale: localeName,
      );

  String get tryToSendAgain => Intl.message("Try to send again");

  String get tuesday => Intl.message("Tuesday");

  String unbannedUser(String username, String targetName) => Intl.message(
        "$username unbanned $targetName",
        name: "unbannedUser",
        args: [username, targetName],
      );

  String get unmuteChat => Intl.message('Unmute chat');

  String unknownEvent(String type) => Intl.message(
        "Unknown event '$type'",
        name: "unknownEvent",
        args: [type],
      );

  String unreadMessages(String unreadEvents) => Intl.message(
        "$unreadEvents unread messages",
        name: "unreadMessages",
        args: [unreadEvents],
      );

  String unreadMessagesInChats(String unreadEvents, String unreadChats) =>
      Intl.message(
        "$unreadEvents unread messages in $unreadChats chats",
        name: "unreadMessagesInChats",
        args: [unreadEvents, unreadChats],
      );

  String userAndOthersAreTyping(String username, String count) => Intl.message(
        "$username and $count others are typing...",
        name: "userAndOthersAreTyping",
        args: [username, count],
      );

  String userAndUserAreTyping(String username, String username2) =>
      Intl.message(
        "$username and $username2 are typing...",
        name: "userAndUserAreTyping",
        args: [username, username2],
      );

  String get username => Intl.message("Username");

  String userIsTyping(String username) => Intl.message(
        "$username is typing...",
        name: "userIsTyping",
        args: [username],
      );

  String userSentUnknownEvent(String username, String type) => Intl.message(
        "$username sent a $type event",
        name: "userSentUnknownEvent",
        args: [username, type],
      );

  String get visibleForAllParticipants =>
      Intl.message("Visible for all participants");

  String get visibleForEveryone => Intl.message("Visible for everyone");

  String get visibilityOfTheChatHistory =>
      Intl.message("Visibility of the chat history");

  String get wednesday => Intl.message("Wednesday");

  String get whoIsAllowedToJoinThisGroup =>
      Intl.message("Who is allowed to join this group");

  String get writeAMessage => Intl.message("Write a message...");

  String get you => Intl.message("You");

  String get youAreInvitedToThisChat =>
      Intl.message("You are invited to this chat");

  String get youAreNoLongerParticipatingInThisChat =>
      Intl.message("You are no longer participating in this chat");

  String get youCannotInviteYourself =>
      Intl.message("You cannot invite yourself");

  String get youHaveBeenBannedFromThisChat =>
      Intl.message("You have been banned from this chat");

  String get yourOwnUsername => Intl.message("Your own username");
}