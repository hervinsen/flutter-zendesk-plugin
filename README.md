[![Bors enabled](https://bors.tech/images/badge_small.svg)](https://app.bors.tech/repositories/21068)


# zendesk-flutter-plugin

A Flutter plugin that integrates Zendesk Chat and Support Center to Flutter

Please check the example folder for a full use case of a flutter app that uses the plugin.

You can check agent status on a specific chat account, send online and offline messages, send attachments like images and videos,
check if there are any unread messages from the user, get platform version, start and end a chat session with this plugin.

## Getting Started

To use this plugin, add `zendesk_flutter_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Get the [Crendentials](https://www.zendesk.com) for your Zendesk chat API project.

Import `package:zendesk_flutter_plugin/zendesk_flutter_plugin.dart`, and initiate `ZendeskFlutterPlugin` with your credentials.

### Integration

```dart
        final ZendeskFlutterPlugin _chatApi = ZendeskFlutterPlugin();
        await _chatApi.init("YOUR ZENDESK ACCOUNT KEY")
```

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference