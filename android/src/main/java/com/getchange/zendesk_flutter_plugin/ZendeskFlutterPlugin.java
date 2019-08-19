package com.getchange.zendesk_flutter_plugin;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.zopim.android.sdk.api.ZopimChat;
import com.zopim.android.sdk.model.VisitorInfo;
import com.zopim.android.sdk.prechat.ZopimChatActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class ZendeskFlutterPlugin implements MethodCallHandler {
  private static final String TAG = "ZendeskFlutterPlugin";

  private Activity context;
  private MethodChannel methodChannel;
  private ZopimChat.DefaultConfig config = null;
  private VisitorInfo visitorInfo = null;

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
      case "init":
        if (config == null) {
          this.visitorInfo = new VisitorInfo.Builder()
              .name((String)call.argument("visitorName"))
              .email((String)call.argument("visitorEmail"))
              .phoneNumber((String)call.argument("visitorPhone"))
              .build();
          final String accountKey = call.argument("accountKey");
          try {
            config = ZopimChat.init(accountKey);
          } catch (Exception e) {
            result.error("UNABLE_TO_INITIALIZE_CHAT", e.getMessage(), e);
            break;
          }
          Log.d(TAG, "Init: accountKey=" +accountKey + " visitorName=" + visitorInfo.getName());
        }
        result.success(null);
        break;
      case "startChat":
        if (config == null) {
          result.error("NOT_INITIALIZED", null, null);
        } else {
          String visitorName = call.argument("visitorName");
          String visitorEmail = call.argument("visitorEmail");
          String visitorPhone = call.argument("visitorPhone");

          VisitorInfo visitorInfo = new VisitorInfo.Builder()
              .name(!TextUtils.isEmpty(visitorName) ? visitorName : this.visitorInfo.getName())
              .email(!TextUtils.isEmpty(visitorEmail) ? visitorEmail : this.visitorInfo.getEmail())
              .phoneNumber(!TextUtils.isEmpty(visitorPhone) ? visitorPhone : this.visitorInfo.getPhoneNumber())
              .build();

          ZopimChat.setVisitorInfo(visitorInfo);

          Log.d(TAG, "StartChat: visitorName=" + visitorInfo.getName());
          context.startActivity(new Intent(context, ZopimChatActivity.class));
          result.success(null);
        }
        break;
      default:
        result.notImplemented();
    }
  }
}
