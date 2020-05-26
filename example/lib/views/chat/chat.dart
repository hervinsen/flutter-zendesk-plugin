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
import 'package:zendesk_flutter_plugin_example/constant/view_constant.dart';
import 'package:zendesk_flutter_plugin_example/constant/zendesk_constant.dart';
import 'package:zendesk_flutter_plugin_example/model/base.dart';
import 'package:zendesk_flutter_plugin_example/util/app_colors.dart';
import 'package:transparent_image/transparent_image.dart';

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
  List<ChatMessage> chatMsg = List<ChatMessage>();
  ConnectionStatus connectionStatus = ConnectionStatus.UNKNOWN;

  List<ChatUser> anotherUsers = List<ChatUser>();

  ChatUser user;

  final ChatUser defaultCSUser = ChatUser(
    name: "Customer Service",
    uid: "DEFAULT_CUSTOMER_SERVICE",
    avatar: "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
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
    setState(() {
      connectionStatus = status;
    });

    print('chatConnectivityUpdated: $status');
  }

  void _chatAccountUpdated(AccountStatus status) {
    print('chatAccountUpdated: $status');
  }

  void _chatAgentsUpdated(List<Agent> agents) {
    setState(() {
      anotherUsers = convertAgentZendeskToFirebaseUserModel(agents);
    });
    print('chatAgentsUpdated:');
    agents.forEach((e) => debugPrint(e.toString()));
  }

  void _chatItemsUpdated(List<ChatItem> chatLog) {
    if (chatLog != null && chatLog.isNotEmpty) {
      setState(() {
        chatMsg = convertFromChatLog(chatLog, user, defaultCSUser,
            anotherUser: anotherUsers);
      });
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
              child: checkConnection() ? chatWidget() : loadingWidget())),
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
      avatarBuilder: (chatUser) {
        return avatarBuilder(chatUser);
      },
      messages: chatMsg,
      onSend: (ChatMessage msg) {
        sendMessage(msg.text);
      },
      inverted: false,
      textInputAction: TextInputAction.send,
      user: user,
      inputDecoration:
          InputDecoration.collapsed(hintText: ViewConstant.chatHintText),
      dateFormat: DateFormat('dd MMM yyyy'),
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
        print(ViewConstant.pleaseWait);
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

  Widget avatarBuilder(ChatUser _user) {
    final constraints = BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width);

    return Column(
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipOval(
              child: Container(
                height: constraints.maxWidth * 0.08,
                width: constraints.maxWidth * 0.08,
                color: Colors.grey,
                child: Center(
                    child: Text(_user.name == null || _user.name.isEmpty
                        ? ''
                        : _user.name[0])),
              ),
            ),
            _user.avatar != null && _user.avatar.length != 0
                ? Center(
                    child: ClipOval(
                      child: FadeInImage.memoryNetwork(
                        image: _user.avatar,
                        placeholder: kTransparentImage,
                        fit: BoxFit.cover,
                        height: constraints.maxWidth * 0.08,
                        width: constraints.maxWidth * 0.08,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
        SizedBox(
          height: constraints.maxWidth * 0.008,
        ),
        Container(
          width: constraints.maxWidth * 0.1,
          child: Text(
            _user.name,
            style: Theme.of(context).textTheme.overline,
          ),
        )
      ],
    );
  }

  bool checkConnection() {
    if (connectionStatus != null &&
        connectionStatus == ConnectionStatus.CONNECTED) {
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
      uid: '${CommonConstant.visitor}:$phoneNumber',
    );
  }

  Future<void> startChat() async {
    await _chatApi.startChat(name,
        visitorEmail: email,
        visitorPhone: phoneNumber,
        department: selectedDepartment.value ?? ZendeskConstant.noDepartment);
  }

  Future<void> sendGoodRating(
      {String message = ViewConstant.goodService}) async {
    await _chatApi.sendChatRating(ChatRating.GOOD, comment: message);
  }

  Future<void> sendBadService(
      {String message = ViewConstant.badService}) async {
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

  static List<ChatMessage> convertFromChatLog(
      List<ChatItem> chatItems, ChatUser currentUser, ChatUser defaultCSUser,
      {@required List<ChatUser> anotherUser}) {
    final result = List<ChatMessage>();

    try {
      if (chatItems == null || chatItems.isEmpty) {
        throw Exception('Chat Is Empty');
      }

      for (final item in chatItems) {
        final message = handleChatMessage(item, currentUser, defaultCSUser,
            anotherUser: anotherUser);
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
      ChatItem item, ChatUser currentUser, ChatUser defaultCSUser,
      {@required List<ChatUser> anotherUser}) {
    ChatUser user =
        item.displayName == currentUser.name ? currentUser : defaultCSUser;

    // Check if another User is Coming to Chat
    if (item.nick != null &&
        [currentUser.uid, defaultCSUser.uid].contains(item.nick) == false) {
      try {
        final filter =
            anotherUser.firstWhere((element) => element.uid == item.nick);
        if (filter != null) {
          user = filter;
        }
      } catch (e) {
//        print(e);
      }
    }

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
    } else if (item.type == ChatItemType.MEMBER_LEAVE) {
      chatMessage.text = '${item.displayName} ${ViewConstant.hasLeft}';

      if (user.uid == currentUser.uid) {
        chatMessage.user = defaultCSUser;
      }
    }
    // IF ZENDESK SCHEDULE IS CLOSE HOUR
    else if (item.attribute('type') == 'ACCOUNT_OFFLINE') {
      chatMessage
        ..user = defaultCSUser
        ..text = ViewConstant.alertCloseHour;
    }

    // check Send Attachment
    else if (item.attachment != null && item.attachment.url != null) {
      chatMessage
        ..text = ''
        ..image = item.attachment.url;
    }

    return chatMessage;
  }

  List<ChatUser> convertAgentZendeskToFirebaseUserModel(List<Agent> agents) {
    final users = List<ChatUser>();
    if (agents == null || agents.isEmpty) {
      return users;
    }

    for (final agent in agents) {
      final user = ChatUser(
        name: agent.displayName,
        uid: agent.id,
      );
      if (agent.avatarUri != null) {
        user.avatar = agent.avatarUri;
      }

      //check agent is typing
      if (agent.isTyping != null) {
        user.customProperties = Map<String, dynamic>();
        if (agent.isTyping) {
          user.customProperties[CommonConstant.isTyping] = true;
        } else {
          user.customProperties[CommonConstant.isTyping] = false;
        }
      }

      users.add(user);
    }
    return users;
  }
}
