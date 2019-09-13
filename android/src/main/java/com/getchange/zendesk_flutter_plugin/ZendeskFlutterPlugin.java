package com.getchange.zendesk_flutter_plugin;

import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.GsonBuilder;
import com.zopim.android.sdk.api.ChatApi;
import com.zopim.android.sdk.api.ZopimChatApi;
import com.zopim.android.sdk.data.DataSource;
import com.zopim.android.sdk.data.observers.AccountObserver;
import com.zopim.android.sdk.data.observers.AgentsObserver;
import com.zopim.android.sdk.data.observers.ChatLogObserver;
import com.zopim.android.sdk.data.observers.ConnectionObserver;
import com.zopim.android.sdk.model.Account;
import com.zopim.android.sdk.model.Agent;
import com.zopim.android.sdk.model.ChatLog;
import com.zopim.android.sdk.model.Connection;
import com.zopim.android.sdk.model.Department;
import com.zopim.android.sdk.model.VisitorInfo;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.app.FlutterFragmentActivity;

import java.util.LinkedHashMap;
import java.util.Map;

import static com.google.gson.FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES;


public class ZendeskFlutterPlugin implements MethodCallHandler {
  private static final String TAG = "ZendeskFlutterPlugin";

  private Handler mainHandler = new Handler(Looper.getMainLooper());
  private PluginRegistry.Registrar registrar;
  private ZopimChatApi.DefaultConfig config = null;
  private ChatApi chatApi = null;
  private String applicationId = null;

  private ConnectionObserver connectionObserver = null;
  private AccountObserver accountObserver = null;
  private AgentsObserver agentsObserver = null;
  private ChatLogObserver chatLogObserver = null;

  private ZendeskFlutterPlugin.EventChannelStreamHandler connectionStreamHandler = new ZendeskFlutterPlugin.EventChannelStreamHandler();
  private ZendeskFlutterPlugin.EventChannelStreamHandler accountStreamHandler = new ZendeskFlutterPlugin.EventChannelStreamHandler();
  private ZendeskFlutterPlugin.EventChannelStreamHandler agentsStreamHandler = new ZendeskFlutterPlugin.EventChannelStreamHandler();
  private ZendeskFlutterPlugin.EventChannelStreamHandler chatItemsStreamHandler = new ZendeskFlutterPlugin.EventChannelStreamHandler();

  private static class EventChannelStreamHandler implements EventChannel.StreamHandler {
    private EventChannel.EventSink eventSink = null;

    public void success(Object event) {
      if (eventSink != null) {
        eventSink.success(event);
      }
    }

    public void error(String errorCode, String errorMessage, Object errorDetails) {
      if (eventSink != null) {
        eventSink.error(errorCode, errorMessage, errorDetails);
      }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      this.eventSink = null;
    }
  }

  public static void registerWith(PluginRegistry.Registrar registrar) {
    if (!(registrar.activity() instanceof FlutterFragmentActivity)) {
      throw new IllegalArgumentException("FRAGMENT_ACTIVITY_REQUIRED. Add dependency \"implementation 'com.android.support:support-v4:28.0.0'\" in build.gradle and extend your MainActivity from FlutterFragmentActivity");
    }
    final MethodChannel callsChannel = new MethodChannel(registrar.messenger(), "plugins.flutter.zendesk_chat_api/calls");
    final EventChannel connectionStatusEventsChannel = new EventChannel(registrar.messenger(), "plugins.flutter.zendesk_chat_api/connection_status_events");
    final EventChannel accountStatusEventsChannel = new EventChannel(registrar.messenger(),"plugins.flutter.zendesk_chat_api/account_status_events");
    final EventChannel agentEventsChannel = new EventChannel(registrar.messenger(),"plugins.flutter.zendesk_chat_api/agent_events");
    final EventChannel chatItemsEventsChannel = new EventChannel(registrar.messenger(),"plugins.flutter.zendesk_chat_api/chat_items_events");

    ZendeskFlutterPlugin plugin = new ZendeskFlutterPlugin(registrar);

    callsChannel.setMethodCallHandler(plugin);

    connectionStatusEventsChannel.setStreamHandler(plugin.connectionStreamHandler);
    accountStatusEventsChannel.setStreamHandler(plugin.accountStreamHandler);
    agentEventsChannel.setStreamHandler(plugin.agentsStreamHandler);
    chatItemsEventsChannel.setStreamHandler(plugin.chatItemsStreamHandler);
  }

  private ZendeskFlutterPlugin(PluginRegistry.Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch(call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "init":
        if (config == null) {
          applicationId = call.argument("applicationId");
          final String accountKey = call.argument("accountKey");
          try {
            config = ZopimChatApi.init(accountKey).disableVisitorInfoStorage();
          } catch (Exception e) {
            result.error("UNABLE_TO_INITIALIZE_CHAT_API", e.getMessage(), e);
            break;
          }
          Log.d(TAG, "Init: accountKey=" +accountKey);
        }
        result.success(null);
        break;
      case "startChat":
        if (config == null) {
          result.error("NOT_INITIALIZED", null, null);
        } else if (chatApi != null) {
          result.error("CHAT_SESSION_ALREADY_OPEN", null, null);
        } else {
          VisitorInfo visitorInfo = new VisitorInfo.Builder()
              .name(call.argument("visitorName"))
              .email(call.argument("visitorEmail"))
              .phoneNumber(call.argument("visitorPhone"))
              .build();

          ZopimChatApi.setVisitorInfo(visitorInfo);

          String department = call.argument("department");
          String tags = call.argument("tags");

          ZopimChatApi.SessionConfig sessionConfig = new ZopimChatApi.SessionConfig();

          if (!TextUtils.isEmpty(department)) {
            sessionConfig.department(department);
          }
          if (!TextUtils.isEmpty(tags)) {
            sessionConfig.tags(tags.split(","));
          }

          if (!TextUtils.isEmpty(applicationId)) {
            sessionConfig.visitorPathTwo(applicationId);
            sessionConfig.visitorPathOne("Mobile Chat connected");
          }

          chatApi = sessionConfig.build((FlutterFragmentActivity)registrar.activity());
          bindChatListeners();

          Log.d(TAG, "StartChat: visitorName=" + visitorInfo.getName() + " email=" +visitorInfo.getName() +
              " phone=" + visitorInfo.getPhoneNumber() + " department=" + department );
          result.success(null);
        }
        break;
      case "endChat":
        if (chatApi == null) {
          result.error("CHAT_NOT_STARTED", null, null);
        } else {
          unbindChatListeners();
          chatApi.endChat();
          chatApi = null;
          Log.d(TAG, "endChat");
          result.success(null);
        }
        break;
      case "sendMessage":
        if (chatApi == null) {
          result.error("CHAT_NOT_STARTED", null, null);
        } else {
          String message = call.argument("message");
          chatApi.send(message);
          Log.d(TAG, "sendMessage: xxx");
          result.success(null);
        }
        break;
      case "sendOfflineMessage":
        if (chatApi == null) {
          result.error("CHAT_NOT_STARTED", null, null);
          return;
        }
        VisitorInfo visitorInfo = chatApi.getConfig().getVisitorInfo();
        if (TextUtils.isEmpty(visitorInfo.getEmail())) {
          result.error("VISITOR_EMAIL_MUST_BE PROVIDED", null, null);
          return;
        }
        Log.d(TAG, "sendOfflineMessage: xxx");
        result.success(chatApi.sendOfflineMessage(visitorInfo.getName(),
            visitorInfo.getEmail(),
            call.argument("message")));

        break;
      default:
        result.notImplemented();
    }
  }

  private void bindChatListeners() {
    unbindChatListeners();

    DataSource datasource = ZopimChatApi.getDataSource();

    connectionObserver = new ConnectionObserver() {
      @Override
      protected void update(Connection connection) {
        mainHandler.post(() -> {
          //Log.d(TAG, "Connection status=" + connection.getStatus());
          connectionStreamHandler.success(connection.getStatus().name());
        });
      }
    };
    datasource.addConnectionObserver(connectionObserver).trigger();

    accountObserver = new AccountObserver() {
      @Override
      public void update(Account account) {
        mainHandler.post(() -> {
          //Log.d(TAG, "Account status=" + account.getStatus());
          accountStreamHandler.success(account.getStatus() != null ? account.getStatus().getValue() : Account.Status.UNKNOWN.getValue());
        });
      }
    };
    datasource.addAccountObserver(accountObserver).trigger();

    agentsObserver = new AgentsObserver() {
      @Override
      protected void update(Map<String, Agent> agents) {
        mainHandler.post(() -> {
          String json = toJson(agents);
          //Log.d(TAG, "Agents: " + json);
          agentsStreamHandler.success(json);
        });
      }
    };
    datasource.addAgentsObserver(agentsObserver).trigger();

    chatLogObserver = new ChatLogObserver() {
      @Override
      protected void update(LinkedHashMap<String, ChatLog> items) {
        mainHandler.post(() -> {
          String json = toJson(items);
          //Log.d(TAG, "ChatLog: " + json);
          chatItemsStreamHandler.success(json);
        });
      }
    };
    datasource.addChatLogObserver(chatLogObserver).trigger();
  }

  private void unbindChatListeners() {
    DataSource datasource = ZopimChatApi.getDataSource();

    if (connectionObserver != null) {
      datasource.deleteConnectionObserver(connectionObserver);
      connectionObserver = null;
    }
    if (accountObserver != null) {
      datasource.deleteAccountObserver(accountObserver);
      accountObserver = null;
    }
    if (agentsObserver != null) {
      datasource.deleteAgentsObserver(agentsObserver);
      agentsObserver = null;
    }
    if (chatLogObserver != null) {
      datasource.deleteChatLogObserver(chatLogObserver);
      chatLogObserver = null;
    }
  }

  private String toJson(Object object) {
    return new GsonBuilder()
        .setFieldNamingPolicy(LOWER_CASE_WITH_UNDERSCORES)
        .create()
        .toJson(object)
        .replaceAll("\\$.+?\":", "\":");
  }
}
