import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zendesk_flutter_plugin/chat_models.dart';
import 'package:zendesk_flutter_plugin/zendesk_flutter_plugin.dart';
import 'package:zendeskchat/constant/zendesk_constant.dart';
import 'package:zendeskchat/model/base.dart';
import 'package:zendeskchat/util/app_colors.dart';

class ChatScreen extends StatefulWidget {
  static const String route = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  BaseModel selectedDepartment;
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  String _platformVersion = 'Unknown';
  String _chatStatus = 'Uninitialized';
  final String _zendeskAccountKey = ZendeskConstant.accountKey;
  final ZendeskFlutterPlugin _chatApi = ZendeskFlutterPlugin();

  StreamSubscription<ConnectionStatus> _chatConnectivitySubscription;
  StreamSubscription<AccountStatus> _chatAccountSubscription;
  StreamSubscription<List<Agent>> _chatAgentsSubscription;
  StreamSubscription<List<ChatItem>> _chatItemsSubscription;

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _chatApi.platformVersion;
    } catch (e) {
      platformVersion = 'Failed to get platform version.';
    }

    _chatConnectivitySubscription =
        _chatApi.onConnectionStatusChanged.listen(_chatConnectivityUpdated);
    _chatAccountSubscription =
        _chatApi.onAccountStatusChanged.listen(_chatAccountUpdated);
    _chatAgentsSubscription =
        _chatApi.onAgentsChanged.listen(_chatAgentsUpdated);
    _chatItemsSubscription =
        _chatApi.onChatItemsChanged.listen(_chatItemsUpdated);

    String chatStatus;
    try {
      await _chatApi.init(_zendeskAccountKey);
      chatStatus = 'INITIALIZED';
    } catch (e) {
      chatStatus = 'Failed to initialize.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _platformVersion = platformVersion;
      _chatStatus = chatStatus;
    });
  }

  @override
  void dispose() {
    _chatConnectivitySubscription?.cancel();
    _chatAccountSubscription?.cancel();
    _chatAgentsSubscription?.cancel();
    _chatItemsSubscription?.cancel();
    _chatApi?.endChat();
    super.dispose();
  }

  void _chatConnectivityUpdated(ConnectionStatus status) {
    print('chatConnectivityUpdated: $status');
  }

  void _chatAccountUpdated(AccountStatus status) {
    print('chatAccountUpdated: $status');
  }

  void _chatAgentsUpdated(List<Agent> agents) {
    print('chatAgentsUpdated:');
    agents.forEach((e) => debugPrint(e.toString()));
  }

  void _chatItemsUpdated(List<ChatItem> chatLog) {
    print('chatItemsUpdated:');
    chatLog.forEach((e) => debugPrint(e.toString()));
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    final arguments = Get.arguments;
    selectedDepartment = arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Department ${selectedDepartment.value ?? '-'}'),
      ),
      body: Container(
        color: AppColors.offWhite,
      ),
    );
  }
}
