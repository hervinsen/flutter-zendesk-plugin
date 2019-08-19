import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_flutter_plugin/zendesk_flutter_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _chatStatus = 'Uninitialized';
  // (so) That's a trial account key
  String _zendeskAccountkey = 'qKizjx120DiKmJNDcGfrkGBVRlbSsEzX';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ZendeskFlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    String chatStatus;
    try {
      await ZendeskFlutterPlugin.init(_zendeskAccountkey, visitorName: 'Test User');
      chatStatus = 'INITIALIZED';
    } on PlatformException {
      chatStatus = 'Failed to initialize.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _chatStatus = chatStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('Chat status: $_chatStatus'),
              RaisedButton(
                onPressed: () async {
                  await ZendeskFlutterPlugin.startChat(visitorName: 'TEST VISITOR');
                },
                child: Text("Start Chat"),
              ),
            ],
          )
        ),
      ),
    );
  }
}
