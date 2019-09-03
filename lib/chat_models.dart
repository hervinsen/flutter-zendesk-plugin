import 'dart:convert';

enum DepartmentStatus {
  UNKNOWN,
  ONLINE,
  OFFLINE,
  AWAY
}

enum ConnectionStatus {
  UNKNOWN,
  NO_CONNECTION,
  CLOSED,
  DISCONNECTED,
  CONNECTING,
  CONNECTED
}

enum AccountStatus {
  UNKNOWN,
  ONLINE,
  OFFLINE,
}

enum ChatItemType {
  UNKNOWN,
  MEMBER_JOIN,
  MEMBER_LEAVE,
  MESSAGE,
  REQUEST_RATING,
}

DepartmentStatus toDepartmentStatus(String value) {
  switch(value) {
    case 'online':
    case 'ONLINE':
      return DepartmentStatus.ONLINE;
    case 'offline':
    case 'OFFLINE':
      return DepartmentStatus.OFFLINE;
    case 'away':
    case 'AWAY':
      return DepartmentStatus.AWAY;
    default:
      return DepartmentStatus.UNKNOWN;
  }
}

ConnectionStatus toConnectionStatus(String value) {
  switch(value) {
    case 'noConnection':
    case 'NO_CONNECTION':
      return ConnectionStatus.NO_CONNECTION;
    case 'closed':
    case 'CLOSED':
      return ConnectionStatus.CLOSED;
    case 'disconnected':
    case 'DISCONNECTED':
      return ConnectionStatus.DISCONNECTED;
    case 'connecting' :
    case 'CONNECTING':
      return ConnectionStatus.CONNECTING;
    case 'connected':
    case 'CONNECTED':
      return ConnectionStatus.CONNECTED;
    default:
      return ConnectionStatus.UNKNOWN;
  }
}

AccountStatus toAccountStatus(String value) {
  switch(value) {
    case 'online':
    case 'ONLINE':
      return AccountStatus.ONLINE;
    case 'offline':
    case 'OFFLINE':
      return AccountStatus.OFFLINE;
    default:
      return AccountStatus.UNKNOWN;
  }
}

ChatItemType toChatItemType(String value) {
  switch (value) {
    case 'chat.memberjoin':
      return ChatItemType.MEMBER_JOIN;
    case 'chat.memberleave':
      return ChatItemType.MEMBER_LEAVE;
    case 'chat.msg':
      return ChatItemType.MESSAGE;
    case 'chat.request.rating':
      return ChatItemType.REQUEST_RATING;
    default:
      return ChatItemType.UNKNOWN;
  }
}

class AbstractModel {
  final String _id;
  final Map<String, dynamic> _attributes;

  AbstractModel(this._id, this._attributes);

  String get id { return _id;}

  dynamic attribute(String attrname) {
    return _attributes != null ? _attributes[attrname] : null;
  }
}

class Department extends AbstractModel {
  Department(String id, Map attributes) : super(id, attributes);

  String get name {
    return attribute('display_name');
  }

  DepartmentStatus get status {
    return toDepartmentStatus(attribute('status'));
  }

  static List<Department> parseDepartmentsJson(String json) {
    var out = List<Department>();
    print('parseDepartmentsJson: \'$json\'');
    jsonDecode(json).forEach((key, value) {
      out.add(Department(key, value));
    });
    return out;
  }
}

class Agent extends AbstractModel {
  Agent(String id, Map attributes) : super(id, attributes);

  String get displayName { return attribute('display_name'); }
  bool get isTyping {return attribute('typing'); }
  String get avatarUri {return attribute('avatar_path'); }

  static List<Agent> parseAgentsJson(String json) {
    var out = List<Agent>();
    print('parseAgentsJson: \'$json\'');
    jsonDecode(json).forEach((key, value) {
      out.add(Agent(key, value));
    });
    return out;
  }
}

class Attachment extends AbstractModel {
  Attachment(Map attributes) : super("", attributes);

  String get mimeType { return attribute('mime_type'); }
  String get name { return attribute('name'); }
  int get size { return attribute('size'); }
  String get type { return attribute('type'); }
  String get url { return attribute('url');}
}

class ChatOption extends AbstractModel {
  ChatOption(Map attributes) : super("", attributes);

  String get label { return attribute('label'); }
  bool get selected { return attribute('selected'); }
}

class ChatItem extends AbstractModel {
  ChatItem(String id, Map attributes) : super(id, attributes);

  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(attribute('timestamp'), isUtc: false);

  ChatItemType get type => toChatItemType(attribute('type'));

  String get displayName => attribute('display_name');

  String get nick => attribute('nick');

  Attachment get attachment {
    dynamic raw = attribute('attachment');
    return (raw != null && raw is Map) ? Attachment(raw) : null;
  }

  bool get unverified => attribute('unverified');
  bool get failed => attribute('failed');

  String get options => attribute('options');

  String get message => attribute('msg');

  List<ChatOption> get convertedOptions {
    List<dynamic> raw = attribute('converted_options');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw.map((optionAttrs) => ChatOption(optionAttrs)).toList();
  }

  int get uploadProgress { return attribute('upload_progress');}

  static List<ChatItem> parseChatItemsJson(String json) {
    var out = List<ChatItem>();
    print('parseChatItemsJson: \'$json\'');
    jsonDecode(json).forEach((key, value) {
      out.add(ChatItem(key, value));
    });
    return out;
  }
}