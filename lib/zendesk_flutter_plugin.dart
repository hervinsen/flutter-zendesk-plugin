import 'dart:async';

import 'package:flutter/services.dart';

class ZendeskFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('zendesk_flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> init(String accountKey, {String visitorName}) async {
    await _channel.invokeMethod('init', <String, dynamic>{
      'accountKey': accountKey,
      'visitorName': visitorName,
    });
  }

  static Future<void> startChat({String visitorName}) async {
    await _channel.invokeMethod('startChat', <String, dynamic>{
      'visitorName': visitorName,
    });
  }
}
