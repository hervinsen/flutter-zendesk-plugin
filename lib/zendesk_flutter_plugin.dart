import 'dart:async';

import 'package:flutter/services.dart';

class ZendeskFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('zendesk_flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> init(String accountKey, {String visitorName, String visitorEmail, String visitorPhone}) async {
    await _channel.invokeMethod('init', <String, dynamic>{
      'accountKey': accountKey,
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone
    });
  }

  static Future<void> updateUser({String visitorName, String visitorEmail, String visitorPhone}) async {
    await _channel.invokeMethod('updateUser', <String, dynamic> {
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone,
    });
  }

  static Future<void> initSupport(String zendeskUrl, String appId, String clientId) async {
    await _channel.invokeMethod('initSupport', <String, dynamic> {
      'zendeskUrl': zendeskUrl,
      'appId': appId,
      'clientId': clientId
    });
  }

  static Future<void> startRequestSupport() async {
    await _channel.invokeMethod('startRequestSupport', <String, dynamic> {
    });
  }

  static Future<void> startListRequestSupport() async {
    await _channel.invokeMethod('startListRequestSupport', <String, dynamic> {

    });
  }

  static Future<void> startChat({String visitorName, String visitorEmail, String visitorPhone}) async {
    await _channel.invokeMethod('startChat', <String, dynamic>{
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone
    });
  }
}
