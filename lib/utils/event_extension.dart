import 'package:famedlysdk/famedlysdk.dart';
import 'package:fluffychat/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'room_state_enums_extensions.dart';

extension LocalizedBody on Event {
  static Set<MessageTypes> textOnlyMessageTypes = {
    MessageTypes.Text,
    MessageTypes.Reply,
    MessageTypes.Notice,
    MessageTypes.Emote,
    MessageTypes.None,
  };

  String getLocalizedBody(BuildContext context,
      {bool withSenderNamePrefix = false, bool hideQuotes = false}) {
    if (this.redacted) {
      return I18n.tr(context)
          .removedBy(redactedBecause.sender.calcDisplayname());
    }
    String localizedBody = body;
    final String senderName = this.sender.calcDisplayname();
    switch (this.type) {
      case EventTypes.Sticker:
        localizedBody = I18n.tr(context).sentASticker(senderName);
        break;
      case EventTypes.Redaction:
        localizedBody = I18n.tr(context).redactedAnEvent(senderName);
        break;
      case EventTypes.RoomAliases:
        localizedBody = I18n.tr(context).changedTheRoomAliases(senderName);
        break;
      case EventTypes.RoomCanonicalAlias:
        localizedBody =
            I18n.tr(context).changedTheRoomInvitationLink(senderName);
        break;
      case EventTypes.RoomCreate:
        localizedBody = I18n.tr(context).createdTheChat(senderName);
        break;
      case EventTypes.RoomJoinRules:
        JoinRules joinRules = JoinRules.values.firstWhere(
            (r) =>
                r.toString().replaceAll("JoinRules.", "") ==
                content["join_rule"],
            orElse: () => null);
        if (joinRules == null) {
          localizedBody = I18n.tr(context).changedTheJoinRules(senderName);
        } else {
          localizedBody = I18n.tr(context).changedTheJoinRulesTo(
              senderName, joinRules.getLocalizedString(context));
        }
        break;
      case EventTypes.RoomMember:
        String text = "Failed to parse member event";
        final String targetName = this.stateKeyUser.calcDisplayname();
        // Has the membership changed?
        final String newMembership = this.content["membership"] ?? "";
        final String oldMembership =
            this.unsigned["prev_content"] is Map<String, dynamic>
                ? this.unsigned["prev_content"]["membership"] ?? ""
                : "";
        if (newMembership != oldMembership) {
          if (oldMembership == "invite" && newMembership == "join") {
            text = I18n.tr(context).acceptedTheInvitation(targetName);
          } else if (oldMembership == "invite" && newMembership == "leave") {
            if (this.stateKey == this.senderId) {
              text = I18n.tr(context).rejectedTheInvitation(targetName);
            } else {
              text = I18n.tr(context)
                  .hasWithdrawnTheInvitationFor(senderName, targetName);
            }
          } else if (oldMembership == "leave" && newMembership == "join") {
            text = I18n.tr(context).joinedTheChat(targetName);
          } else if (oldMembership == "join" && newMembership == "ban") {
            text = I18n.tr(context).kickedAndBanned(senderName, targetName);
          } else if (oldMembership == "join" &&
              newMembership == "leave" &&
              this.stateKey != this.senderId) {
            text = I18n.tr(context).kicked(senderName, targetName);
          } else if (oldMembership == "join" &&
              newMembership == "leave" &&
              this.stateKey == this.senderId) {
            text = I18n.tr(context).userLeftTheChat(targetName);
          } else if (oldMembership == "invite" && newMembership == "ban") {
            text = I18n.tr(context).bannedUser(senderName, targetName);
          } else if (oldMembership == "leave" && newMembership == "ban") {
            text = I18n.tr(context).bannedUser(senderName, targetName);
          } else if (oldMembership == "ban" && newMembership == "leave") {
            text = I18n.tr(context).unbannedUser(senderName, targetName);
          } else if (newMembership == "invite") {
            text = I18n.tr(context).invitedUser(senderName, targetName);
          } else if (newMembership == "join") {
            text = I18n.tr(context).joinedTheChat(targetName);
          }
        } else if (newMembership == "join") {
          final String newAvatar = this.content["avatar_url"] ?? "";
          final String oldAvatar =
              this.unsigned["prev_content"] is Map<String, dynamic>
                  ? this.unsigned["prev_content"]["avatar_url"] ?? ""
                  : "";

          final String newDisplayname = this.content["displayname"] ?? "";
          final String oldDisplayname =
              this.unsigned["prev_content"] is Map<String, dynamic>
                  ? this.unsigned["prev_content"]["displayname"] ?? ""
                  : "";

          // Has the user avatar changed?
          if (newAvatar != oldAvatar) {
            text = I18n.tr(context).changedTheProfileAvatar(targetName);
          }
          // Has the user avatar changed?
          else if (newDisplayname != oldDisplayname) {
            text = I18n.tr(context)
                .changedTheDisplaynameTo(targetName, newDisplayname);
          }
        }
        localizedBody = text;
        break;
      case EventTypes.RoomPowerLevels:
        localizedBody = I18n.tr(context).changedTheChatPermissions(senderName);
        break;
      case EventTypes.RoomName:
        localizedBody =
            I18n.tr(context).changedTheChatNameTo(senderName, content["name"]);
        break;
      case EventTypes.RoomTopic:
        localizedBody = I18n.tr(context)
            .changedTheChatDescriptionTo(senderName, content["topic"]);
        break;
      case EventTypes.RoomAvatar:
        localizedBody = I18n.tr(context).changedTheChatAvatar(senderName);
        break;
      case EventTypes.GuestAccess:
        GuestAccess guestAccess = GuestAccess.values.firstWhere(
            (r) =>
                r.toString().replaceAll("GuestAccess.", "") ==
                content["guest_access"],
            orElse: () => null);
        if (guestAccess == null) {
          localizedBody =
              I18n.tr(context).changedTheGuestAccessRules(senderName);
        } else {
          localizedBody = I18n.tr(context).changedTheGuestAccessRulesTo(
              senderName, guestAccess.getLocalizedString(context));
        }
        break;
      case EventTypes.HistoryVisibility:
        HistoryVisibility historyVisibility = HistoryVisibility.values
            .firstWhere(
                (r) =>
                    r.toString().replaceAll("HistoryVisibility.", "") ==
                    content["history_visibility"],
                orElse: () => null);
        if (historyVisibility == null) {
          localizedBody =
              I18n.tr(context).changedTheHistoryVisibility(senderName);
        } else {
          localizedBody = I18n.tr(context).changedTheHistoryVisibilityTo(
              senderName, historyVisibility.getLocalizedString(context));
        }
        break;
      case EventTypes.Encryption:
        localizedBody =
            I18n.tr(context).activatedEndToEndEncryption(senderName);
        if (!room.client.encryptionEnabled) {
          localizedBody += ". " + I18n.tr(context).needPantalaimonWarning;
        }
        break;
      case EventTypes.Encrypted:
        localizedBody = I18n.tr(context).couldNotDecryptMessage;
        break;
      case EventTypes.Message:
        switch (this.messageType) {
          case MessageTypes.Image:
            localizedBody = I18n.tr(context).sentAPicture(senderName);
            break;
          case MessageTypes.File:
            localizedBody = I18n.tr(context).sentAFile(senderName);
            break;
          case MessageTypes.Audio:
            localizedBody = I18n.tr(context).sentAnAudio(senderName);
            break;
          case MessageTypes.Video:
            localizedBody = I18n.tr(context).sentAVideo(senderName);
            break;
          case MessageTypes.Location:
            localizedBody = I18n.tr(context).sharedTheLocation(senderName);
            break;
          case MessageTypes.Sticker:
            localizedBody = I18n.tr(context).sentASticker(senderName);
            break;
          case MessageTypes.Emote:
            localizedBody = "* $body";
            break;
          case MessageTypes.BadEncrypted:
            localizedBody =
                "🔒 " + I18n.tr(context).couldNotDecryptMessage + ": " + body;
            break;
          case MessageTypes.Text:
          case MessageTypes.Notice:
          case MessageTypes.None:
          case MessageTypes.Reply:
            localizedBody = body;
            break;
        }
        break;
      default:
        localizedBody = I18n.tr(context).unknownEvent(this.typeKey);
    }

    // Hide quotes
    if (hideQuotes) {
      List<String> lines = localizedBody.split("\n");
      lines.removeWhere((s) => s.startsWith("> ") || s.isEmpty);
      localizedBody = lines.join("\n");
    }

    // Add the sender name prefix
    if (withSenderNamePrefix &&
        this.type == EventTypes.Message &&
        textOnlyMessageTypes.contains(this.messageType)) {
      final String senderNameOrYou = this.senderId == room.client.userID
          ? I18n.tr(context).you
          : senderName;
      localizedBody = "$senderNameOrYou: $localizedBody";
    }

    return localizedBody;
  }
}
