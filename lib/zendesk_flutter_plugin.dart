import 'dart:async';

import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'chat_models.dart';

class ZendeskFlutterPlugin {

  static ZendeskFlutterPlugin _instance;
  static const MethodChannel _callsChannel = MethodChannel('plugins.flutter.zendesk_chat_api/calls');
  static const EventChannel _connectionStatusEventsChannel = EventChannel('plugins.flutter.zendesk_chat_api/connection_status_events');
  static const EventChannel _accountStatusEventsChannel = EventChannel('plugins.flutter.zendesk_chat_api/account_status_events');
  static const EventChannel _agentEventsChannel = EventChannel('plugins.flutter.zendesk_chat_api/agent_events');
  static const EventChannel _chatItemsEventsChannel = EventChannel('plugins.flutter.zendesk_chat_api/chat_items_events');

  Stream<ConnectionStatus> _connectionStatusEventsStream;
  Stream<AccountStatus> _accountStatusEventsStream;
  Stream<List<Agent>> _agentEventsStream;
  Stream<List<ChatItem>> _chatItemsEventsStream;

  factory ZendeskFlutterPlugin() {
    if (_instance == null) {
      _instance = ZendeskFlutterPlugin._();
    }
    return _instance;
  }

  ZendeskFlutterPlugin._();

  Future<String> get platformVersion async {
    final String version = await _callsChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> init(String accountKey) async {
    await _callsChannel.invokeMethod('init', <String, dynamic> {
      'accountKey': accountKey
    });
  }

  Future<void> startChat(String visitorName, {String visitorEmail, String visitorPhone, String department, List<String> tags}) async {
    return await _callsChannel.invokeMethod('startChat', <String, dynamic> {
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone,
      'department': department,
      'tags': tags?.join(',')
    });
  }

  Future<void> endChat() async {
    return await _callsChannel.invokeMethod('endChat');
  }

  Future<List<Department>> getDepartments() async {
    final dynamic json = await _callsChannel.invokeMethod('getDepartments');
    return Department.parseDepartmentsJson(json);
  }

  Future<void> setDepartment(String department) async {
    return await _callsChannel.invokeMethod('setDepartment', <String, dynamic> {
      'department': department
    });
  }

  Future<void> sendMessage(String message) async {
    return await _callsChannel.invokeMethod('sendMessage',  <String, dynamic> {
      'message': message
    });
  }

  Future<bool> sendOfflineMessage(String visitorName, String visitorEmail, String message) async {
    return await _callsChannel.invokeMethod('sendOfflineMessage', <String, dynamic> {
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'message': message
    });
  }

  Stream<ConnectionStatus> get onConnectionStatusChanged {
    if (_connectionStatusEventsStream == null) {
      _connectionStatusEventsStream = _connectionStatusEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => toConnectionStatus(event));
    }
    return _connectionStatusEventsStream;
  }

  Stream<AccountStatus> get onAccountStatusChanged {
    if (_accountStatusEventsStream == null) {
      _accountStatusEventsStream = _accountStatusEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => toAccountStatus(event));
    }
    return _accountStatusEventsStream;
  }

  Stream<List<Agent>> get onAgentsChanged {
    if (_agentEventsStream == null) {
      _agentEventsStream = _agentEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => Agent.parseAgentsJson(event));
    }
    return _agentEventsStream;
  }

  Stream<List<ChatItem>> get onChatItemsChanged {
    if (_chatItemsEventsStream == null) {
      _chatItemsEventsStream = _chatItemsEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) {
            if (Platform.isAndroid) {
              return ChatItem.parseChatItemsJsonForAndroid(event);
            } else if (Platform.isIOS) {
              return ChatItem.parseChatItemsJsonForIOS(event);
            }
          });
    }
    return _chatItemsEventsStream;
  }
}
