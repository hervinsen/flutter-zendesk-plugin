import 'package:dash_chat/dash_chat.dart';
import 'package:zendesk_flutter_plugin/chat_models.dart';

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
}

class _P {
  static const String name = 'display_name';
  static const String nick = 'nick';
  static const String message = 'msg';
  static const String type = 'type';
  static const String timestamp = 'timestamp';
  static const String uploadProgress = 'upload_progress';
}
