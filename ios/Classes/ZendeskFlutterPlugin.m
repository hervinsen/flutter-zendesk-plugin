#import "ZendeskFlutterPlugin.h"

@implementation EventChannelStreamHandler

- (void) send:(NSObject*)event {
  if (self.eventSink) {
    self.eventSink(event);
  }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
  self.eventSink = events;
  return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

@end

@implementation ZendeskFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* callsChannel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.zendesk_chat_api/calls"
      binaryMessenger:[registrar messenger]];

  FlutterEventChannel* connectionStatusEventsChannel = [FlutterEventChannel
      eventChannelWithName:@"plugins.flutter.zendesk_chat_api/connection_status_events"
      binaryMessenger:[registrar messenger]];

  FlutterEventChannel* accountStatusEventsChannel = [FlutterEventChannel
      eventChannelWithName:@"plugins.flutter.zendesk_chat_api/account_status_events"
      binaryMessenger:[registrar messenger]];

  FlutterEventChannel* agentEventsChannel = [FlutterEventChannel
      eventChannelWithName:@"plugins.flutter.zendesk_chat_api/agent_events"
      binaryMessenger:[registrar messenger]];
      
  FlutterEventChannel* chatItemsEventsChannel = [FlutterEventChannel
      eventChannelWithName:@"plugins.flutter.zendesk_chat_api/chat_items_events"
      binaryMessenger:[registrar messenger]];

  ZendeskFlutterPlugin* instance = [[ZendeskFlutterPlugin alloc] init];
  
  instance.connectionStreamHandler = [[EventChannelStreamHandler alloc] init];
  instance.accountStreamHandler = [[EventChannelStreamHandler alloc] init];
  instance.agentsStreamHandler = [[EventChannelStreamHandler alloc] init];
  instance.chatItemsStreamHandler = [[EventChannelStreamHandler alloc] init];
  
  [registrar addMethodCallDelegate:instance channel:callsChannel];
  [connectionStatusEventsChannel setStreamHandler:instance.connectionStreamHandler];
  [accountStatusEventsChannel setStreamHandler:instance.accountStreamHandler];
  [agentEventsChannel setStreamHandler:instance.agentsStreamHandler];
  [chatItemsEventsChannel setStreamHandler:instance.chatItemsStreamHandler];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"init" isEqualToString:call.method]) {
    self.accountKey = call.arguments[@"accountKey"];
    result(nil);
  } else if ([@"startChat" isEqualToString:call.method]) {
    if ([self.accountKey length] == 0) {
      result([FlutterError errorWithCode:@"NOT_INITIALIZED" message:nil details:nil]);
      return;
    }
    if (self.chatApi) {
      result([FlutterError errorWithCode:@"CHAT_SESSION_ALREADY_OPEN" message:nil details:nil]);
      return;
    }
    self.chatApi = [ZDCChatAPI instance];
    
    self.chatApi.visitorInfo.shouldPersist = NO;
    self.chatApi.visitorInfo.name = [self argumentAsString:call forName:@"visitorName"];
    self.chatApi.visitorInfo.email = [self argumentAsString:call forName:@"visitorEmail"];
    self.chatApi.visitorInfo.phone = [self argumentAsString:call forName:@"visitorPhone"];
    
    ZDCAPIConfig *chatConfig = [[ZDCAPIConfig alloc] init];
    chatConfig.department = [self argumentAsString:call forName:@"department"];
    NSString *tags = [self argumentAsString:call forName:@"tags"];
    if ([tags length] != 0) {
      chatConfig.tags = [tags componentsSeparatedByString:@","];
    }
    
    [self bindChatListeners];
    [self.chatApi startChatWithAccountKey:self.accountKey config: chatConfig];
    result(nil);
  } else if ([@"endChat" isEqualToString:call.method]) {
    if (self.chatApi != nil) {
      [self unbindChatListeners];
      [self.chatApi endChat];
      self.chatApi = nil;
    }
    result(nil);
  } else if ([@"sendMessage" isEqualToString:call.method]) {
    if (self.chatApi == nil) {
      result([FlutterError errorWithCode:@"CHAT_NOT_STARTED" message:nil details:nil]);
      return;
    }
    [self.chatApi sendChatMessage:call.arguments[@"message"]];
    result(nil);
  } else if ([@"sendAttachment" isEqualToString:call.method]) {
    if (self.chatApi == nil) {
      result([FlutterError errorWithCode:@"CHAT_NOT_STARTED" message:nil details:nil]);
      return;
    }
    if (!self.chatApi.fileSendingEnabled) {
      result([FlutterError errorWithCode:@"ATTACHMENT_SEND_DISABLED" message:nil details:nil]);
      return;
    }
    NSString* pathname = [self argumentAsString:call forName:@"pathname"];
    if ([pathname length] == 0) {
      result([FlutterError errorWithCode:@"ATTACHMENT_EMPTY_PATHNAME" message:nil details:nil]);
      return;
    }
    NSString* filename = [pathname lastPathComponent];
    [self.chatApi uploadFileWithPath:pathname name:filename];
    result(nil);
  } else if ([@"sendOfflineMessage" isEqualToString:call.method]) {
    if (self.chatApi == nil) {
      result([FlutterError errorWithCode:@"CHAT_NOT_STARTED" message:nil details:nil]);
      return;
    }
    [self.chatApi sendOfflineMessage:call.arguments[@"message"]];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString*) argumentAsString:(FlutterMethodCall*)call forName:(NSString*)argName {
  NSString* value = call.arguments[argName];
  return [value isKindOfClass:[NSString class]] ? value : nil;
}


- (void) bindChatListeners {
  [self unbindChatListeners];
  [self.chatApi addObserver:self forConnectionEvents:@selector(connectionStateUpdated)];
  [self.chatApi addObserver:self forAgentEvents:@selector(agentsUpdated)];
  [self.chatApi addObserver:self forAccountEvents:@selector(accountUpdated)];
  [self.chatApi addObserver:self forChatLogEvents:@selector(chatLogUpdated)];
}

- (void) connectionStateUpdated {
  NSString *value;
  switch (self.chatApi.connectionStatus) {
    case ZDCConnectionStatusConnecting:
      value = @("CONNECTING");
      break;
    case ZDCConnectionStatusConnected:
      value = @("CONNECTED");
      break;
    case ZDCConnectionStatusClosed:
      value = @("CLOSED");
      break;
    case ZDCConnectionStatusDisconnected:
      value = @("DISCONNECTED");
      break;
    case ZDCConnectionStatusNoConnection:
      value = @("NO_CONNECTION");
      break;
    default:
      value = @("UNKNOWN");
      break;
  }
  [self.connectionStreamHandler send:value];
}

- (void) agentsUpdated {
  NSMutableDictionary *out = [[NSMutableDictionary alloc] initWithCapacity:[self.chatApi.agents count]];
  [self.chatApi.agents enumerateKeysAndObjectsUsingBlock:^(NSString *key, ZDCChatAgent *agent, BOOL *stop) {
    NSMutableDictionary *agentDict = [[NSMutableDictionary alloc] init];
    [agentDict setValue:agent.displayName forKey:@"displayName"];
    [agentDict setValue:agent.avatarURL forKey:@"avatarURL"];
    [agentDict setValue:@(agent.typing) forKey:@"typing"];
    [agentDict setValue:agent.title forKey:@"title"];
    [out setObject:agentDict forKey:key];
  }];
  [self.agentsStreamHandler send:[self toJson:out]];
  
}

- (void) accountUpdated {
  [self.accountStreamHandler send:(self.chatApi.isAccountOnline ? @("ONLINE") : @("OFFLINE"))];
}

- (void) chatLogUpdated {
  NSArray<ZDCChatEvent*> *chatLog = self.chatApi.livechatLog;
  NSMutableArray* out = [[NSMutableArray alloc] initWithCapacity:[chatLog count]];
  for (ZDCChatEvent* event in chatLog) {
    NSMutableDictionary* chatItem = [[NSMutableDictionary alloc] init];
    [chatItem setValue:event.eventId forKey:@"id"];
    [chatItem setValue:event.timestamp forKey:@"timestamp"];
    [chatItem setValue:event.nickname forKey:@"nick"];
    [chatItem setValue:event.displayName forKey:@"display_name"];
    [chatItem setValue:event.message forKey:@"msg"];
    [chatItem setValue:[self chatEventTypeToString:event.type] forKey:@"type"];
    [chatItem setValue:@(event.verified) forKey:@"verified"];
    if ([event.options count] > 0) {
      [chatItem setValue:event.options forKey:@"options"];
      [chatItem setValue:[[NSNumber alloc] initWithLong:event.selectedOptionIndex] forKey:@"selectedOptionIndex"];
    }
    if (event.attachment != nil) {
      [chatItem setValue:[self attachmentToDictionary:event.attachment] forKey:@"attachment"];
    }
    [out addObject:chatItem];
  }
  [self.chatItemsStreamHandler send:[self toJson:out]];
}

- (void) unbindChatListeners {
  [self.chatApi removeObserverForConnectionEvents:self];
  [self.chatApi removeObserverForAgentEvents:self];
  [self.chatApi removeObserverForAccountEvents:self];
  [self.chatApi removeObserverForConnectionEvents:self];
}

- (NSString*) chatEventTypeToString:(ZDCChatEventType)type {
  switch (type) {
    case ZDCChatEventTypeMemberJoin:
      return @"chat.memberjoin";
    case ZDCChatEventTypeMemberLeave:
      return @"chat.memberleave";
    case ZDCChatEventTypeSystemMessage:
      return @"chat.systemmsg";
    case ZDCChatEventTypeTriggerMessage:
      return @"chat.triggermsg";
    case ZDCChatEventTypeAgentMessage:
    case ZDCChatEventTypeVisitorMessage:
      return @"chat.msg";
    case ZDCChatEventTypeRating:
      return @"chat.request.rating";
    default:
      return @"UNKNOWN";
  }
}

- (NSDictionary*) attachmentToDictionary:(ZDCChatAttachment*)attachment {
  if (attachment == nil) {
    return nil;
  }
  NSMutableDictionary* out = [[NSMutableDictionary alloc] init];
  [out setValue:attachment.url forKey:@"url"];
  [out setValue:attachment.thumbnailURL forKey:@"thumbnail_url"];
  [out setValue:attachment.fileSize forKey:@"size"];
  [out setValue:attachment.mimeType forKey:@"mime_type"];
  [out setValue:attachment.fileName forKey:@"name"];
  return out;
}

- (NSString*) toJson:(NSObject*)object {
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
  if (error != nil) {
    NSLog(@("An json serialization error happened: %@"), error);
    return nil;
  } else if ([jsonData length] == 0) {
    return nil;
  } else {
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
}

@end
