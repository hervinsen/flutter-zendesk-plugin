import 'package:dash_chat/dash_chat.dart';
import 'package:zendesk_flutter_plugin/chat_models.dart';
import 'package:zendesk_flutter_plugin_example/constant/view_constant.dart';

class ChatAttribute {
  String id;
  String name;
  String nick;
  ChatItemType type;
  String message;
  DateTime timestamp;
  int uploadProgress;

  ChatAttribute(
      {this.id,
      this.name,
      this.nick,
      this.message,
      this.type,
      this.timestamp,
      this.uploadProgress});

  factory ChatAttribute.fromChatItem(ChatItem chatItem) {
    final result = ChatAttribute();

    try {
      result.id = chatItem.id;
      result.name = chatItem.displayName;
      result.nick = chatItem.nick;
      result.type = chatItem.type;
      result.message = chatItem.message;
      result.timestamp = chatItem.timestamp;
      result.uploadProgress = chatItem.uploadProgress;
    } catch (e) {}

    return result;
  }

  static List<ChatMessage> convertFromMessageAttribute(
      List<ChatAttribute> chatAttributes,
      ChatUser currentUser,
      ChatUser anotherUser) {
    final result = List<ChatMessage>();

    try {
      if (chatAttributes == null || chatAttributes.isEmpty) {
        throw Exception('Chat Is Empty');
      }

      for (final attr in chatAttributes) {
        ChatUser user =
            attr.name == currentUser.name ? currentUser : anotherUser;
        final message = ChatMessage(
          user: user,
          text: attr.message ?? '-',
          id: attr.id,
          createdAt: attr.timestamp,
        );

        result.add(message);
      }
    } catch (e) {
      print(e);
    }

    return result;
  }

  static List<ChatAttribute> fromFullListChatItem(List<ChatItem> chatLog) {
    var result = List<ChatAttribute>();

    try {
      for (final log in chatLog) {
        result.add(ChatAttribute.fromChatItem(log));
      }
    } catch (e) {
      result = List<ChatAttribute>();
    }

    return result;
  }

  static List<ChatMessage> convertFromChatLog(
      List<ChatItem> chatItems, ChatUser currentUser, ChatUser defaultCSUser) {
    final result = List<ChatMessage>();

    try {
      if (chatItems == null || chatItems.isEmpty) {
        throw Exception('Chat Is Empty');
      }

      for (final item in chatItems) {
        final message = handleChatMessage(item, currentUser, defaultCSUser);
        if (message != null) {
          result.add(message);
        }
      }
    } catch (e) {
      print(e);
    }

    return result;
  }

  static ChatMessage handleChatMessage(
      ChatItem item, ChatUser currentUser, ChatUser defaultCSUser) {
    ChatUser user =
        item.displayName == currentUser.name ? currentUser : defaultCSUser;

    final chatMessage = ChatMessage(
      user: user,
      text: item.message ?? '',
      id: item.id,
      createdAt: item.timestamp,
    );

    // Check Visitor Join Chat
    if (item.type == ChatItemType.MEMBER_JOIN) {
      final tempMsg = '${item.displayName} ${ViewConstant.hasJoin}';
      chatMessage.text = tempMsg;

      // IF current User connect no need to add to chat
      // Already have greeting from zendesk
      if (user.uid == currentUser.uid) {
        /*
        chatMessage.user = defaultCSUser;
        chatMessage.text = '${ViewConstant.welcome} ${user.name}';
        */

        return null;
      }
    }

    // check Send Attachment
    else if (item.attachment != null && item.attachment.url != null) {
      chatMessage
        ..text = ''
        ..image = item.attachment.url;
    }

    return chatMessage;
  }
}

class _P {
  static const String name = 'display_name';
  static const String nick = 'nick';
  static const String message = 'msg';
  static const String type = 'type';
  static const String timestamp = 'timestamp';
  static const String uploadProgress = 'upload_progress';
}
