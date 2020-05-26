import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zendesk_flutter_plugin/chat_models.dart';
import 'package:zendesk_flutter_plugin/zendesk_flutter_plugin.dart';
import 'package:zendesk_flutter_plugin_example/constant/common.dart';
import 'package:zendesk_flutter_plugin_example/constant/zendesk_constant.dart';
import 'package:zendesk_flutter_plugin_example/model/base.dart';
import 'package:zendesk_flutter_plugin_example/model/chat_attribute_model.dart';
import 'package:zendesk_flutter_plugin_example/util/app_colors.dart';

class ChatScreen extends StatefulWidget {
  static const String route = 'chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AfterLayoutMixin {
  BaseModel selectedDepartment;
  String name;
  String phoneNumber;
  String email;
  List<ChatMessage> chatMsg;

  ChatUser user;

  final ChatUser otherUser = ChatUser(
    name: "Agent",
    uid: "25649654",
  );

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
    if (chatLog != null && chatLog.isNotEmpty) {
      final tmp = ChatAttribute.fromFullListChatItem(chatLog);
      chatMsg = ChatAttribute.convertFromMessageAttribute(tmp, user, otherUser);
      print(chatMsg);
      setState(() {});
    }
    print('chatItemsUpdated:');
    chatLog.forEach((e) => debugPrint(e.toString()));
  }

  @override
  void initState() {
    super.initState();

    handleIncomingArgument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Department ${selectedDepartment.value ?? '-'}'),
      ),
      body: Container(
          color: AppColors.offWhite,
          child: Container(
              child: checkMessage() ? chatWidget() : loadingWidget())),
    );
  }

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget chatWidget() {
    return DashChat(
      messages: chatMsg,
      onSend: (ChatMessage msg) {
        sendMessage(msg.text);
      },
      inverted: false,
      textInputAction: TextInputAction.send,
      user: user,
      inputDecoration:
          InputDecoration.collapsed(hintText: "Add message here..."),
      dateFormat: DateFormat('yyyy-MMM-dd'),
      timeFormat: DateFormat('HH:mm'),
      showUserAvatar: false,
      showAvatarForEveryMessage: false,
      scrollToBottom: false,
      onPressAvatar: (ChatUser user) {
        print("OnPressAvatar: ${user.name}");
      },
      onLongPressAvatar: (ChatUser user) {
        print("OnLongPressAvatar: ${user.name}");
      },
      inputMaxLines: 5,
      messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
      alwaysShowSend: true,
      inputTextStyle: TextStyle(fontSize: 16.0),
      inputContainerStyle: BoxDecoration(
        border: Border.all(width: 0.0),
        color: Colors.white,
      ),
      shouldShowLoadEarlier: false,
      showTraillingBeforeSend: true,
      onLoadEarlier: () {
        print("laoding...");
      },
      trailing: <Widget>[
        IconButton(
          icon: Icon(Icons.photo),
          onPressed: () async {
            await sendAttachment();
          },
        )
      ],
    );
  }

  bool checkMessage() {
    if (chatMsg != null && chatMsg.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void handleIncomingArgument() {
    final Map<String, dynamic> arguments = Get.arguments;
    selectedDepartment = arguments['selectedDepartment'];
    name = arguments[CommonConstant.name];
    phoneNumber = arguments[CommonConstant.phoneNumber];
    email = arguments[CommonConstant.email];

    user = ChatUser(
      name: name,
      uid: phoneNumber,
      avatar: "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
    );
  }

  Future<void> startChat() async {
    await _chatApi.startChat(name,
        visitorEmail: email,
        visitorPhone: phoneNumber,
        department: selectedDepartment.value ?? ZendeskConstant.noDepartment);
  }

  Future<void> sendGoodRating({String message = 'Good service'}) async {
    await _chatApi.sendChatRating(ChatRating.GOOD, comment: message);
  }

  Future<void> sendBadService({String message = 'Bad service'}) async {
    await _chatApi.sendChatRating(ChatRating.BAD, comment: message);
  }

  Future<void> sendMessage(String message) async {
    await _chatApi.sendMessage(message);
  }

  Future<void> sendAttachment() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      try {
        await _chatApi.sendAttachment(file.path);
      } on PlatformException catch (e) {
        debugPrint('An error occurred: ${e.code}');
      }
    }
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    await initPlatformState();
    await startChat();
  }
}
