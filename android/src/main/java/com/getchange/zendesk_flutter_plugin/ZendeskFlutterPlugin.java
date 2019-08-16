package com.getchange.zendesk_flutter_plugin;

import android.app.Activity;
import android.content.Intent;
import com.zopim.android.sdk.api.ZopimChat;
import com.zopim.android.sdk.prechat.ZopimChatActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class ZendeskFlutterPlugin implements MethodCallHandler {
  private Activity context;
  private MethodChannel methodChannel;
  private ZopimChat.DefaultConfig config = null;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "zendesk_flutter_plugin");
    channel.setMethodCallHandler(new ZendeskFlutterPlugin(registrar.activity(), channel));
  }

  private ZendeskFlutterPlugin(Activity activity, MethodChannel methodChannel) {
    this.context = activity;
    this.methodChannel = methodChannel;
    this.methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch(call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "startChat":
        if (config == null) {
          try {
            // TODO: move accountKey to config properties
            config = ZopimChat.init("4PBQNia9qItVDD98qmCYEfVesWLR4IFC");
          } catch (Exception e) {
            result.error("UNABLE_TO_INITIALIZE_CHAT", e.getMessage(), e);
            break;
          }
        }
        context.startActivity(new Intent(context, ZopimChatActivity.class));
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }
}
