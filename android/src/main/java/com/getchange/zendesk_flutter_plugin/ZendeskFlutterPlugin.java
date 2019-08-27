package com.getchange.zendesk_flutter_plugin;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;
import com.zendesk.util.StringUtils;
import com.zopim.android.sdk.api.ZopimChat;
import com.zopim.android.sdk.model.VisitorInfo;
import com.zopim.android.sdk.prechat.PreChatForm;
import com.zopim.android.sdk.prechat.ZopimChatActivity;
import com.zopim.android.sdk.prechat.ZopimPreChatFragment;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import zendesk.core.UserProvider;
import zendesk.core.Zendesk;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.request.RequestActivity;
import zendesk.support.requestlist.RequestListActivity;
import zendesk.support.Support;
import zendesk.core.AnonymousIdentity;





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
      case "initSupport":
        if (config == null) {
          final String zendeskUrl = call.argument("zendeskUrl");
          final String appId = call.argument("appId");
          final String clientId = call.argument("clientId");
          try {
            Zendesk.INSTANCE.init(context, zendeskUrl,
            appId,
            clientId);
            Zendesk.INSTANCE.setIdentity(
              new AnonymousIdentity.Builder().build()
            );
            Support.INSTANCE.init(Zendesk.INSTANCE);
          }
          catch (Exception e) {
            result.error("UNABLE_TO_INITIALIZE_CHAT", e.getMessage(), e);
            break;
          }
          Log.d(TAG, "InitSupport");
        }
        result.success(null);
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

          PreChatForm preChatConfig = new PreChatForm.Builder()
              .department(PreChatForm.Field.REQUIRED_EDITABLE)
              .message(PreChatForm.Field.REQUIRED_EDITABLE)
              .build();

          ZopimChat.SessionConfig config = new ZopimChat.SessionConfig().preChatForm(preChatConfig);
          Log.d(TAG, "StartChat: visitorName=" + visitorInfo.getName());
          ZopimChatActivity.startActivity(context, config);
          result.success(null);
        }
        break;
      case "startRequestSupport":
        if(config == null) {
          result.error("NOT INITIALIZED", null, null);
        } else {
          RequestActivity.builder()
            .show(context);
          result.success(null);
        }
      case "startListRequestSupport":
        if (config == null) { 
          result.error("NOT INITIALIZED", null, null);
        } else {
          RequestListActivity.builder()
            .show(context);
          result.success(null);
        }
      case "updateUser":
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

          Log.d(TAG, "UpdateUser: visitorName=" + visitorInfo.getName());
          ZopimChat.setVisitorInfo(visitorInfo);
          result.success(null);
        }
      default:
        result.notImplemented();
    }
  }
}
