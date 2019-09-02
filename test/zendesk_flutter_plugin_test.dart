import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_flutter_plugin/zendesk_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('zendesk_flutter_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZendeskFlutterPlugin().platformVersion, '42');
  });
}
