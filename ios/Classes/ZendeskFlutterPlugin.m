#import "ZendeskFlutterPlugin.h"

#import <ZDCChat/ZDCChat.h>

@implementation ZendeskFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"zendesk_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  ZendeskFlutterPlugin* instance = [[ZendeskFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    [ZDCChat initializeWithAccountKey:call.arguments[@"accountKey"]];
    result(nil);
  } else if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"updateUser" isEqualToString:call.method]) {
    NSString *name = call.arguments[@"visitorName"];
    NSString *email = call.arguments[@"visitorEmail"];
    NSString *phoneNumber = call.arguments[@"visitorPhone"];
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *user) {
      if (![name isKindOfClass:[NSNull class]]) {
              user.name = name;
      }
      if (![email isKindOfClass:[NSNull class]]) {
              user.email = email;
      }
      if (![phoneNumber isKindOfClass:[NSNull class]]) {
              user.phone = phoneNumber;
      }
    }];
    result(nil);
  } else if ([@"startChat" isEqualToString:call.method]) {
    NSString *name = call.arguments[@"visitorName"];
    NSString *email = call.arguments[@"visitorEmail"];
    NSString *phoneNumber = call.arguments[@"visitorPhone"];
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *user) {
      if (![name isKindOfClass:[NSNull class]]) {
              user.name = name;
          }
      if (![email isKindOfClass:[NSNull class]]) {
              user.email = email;
          }
      if (![phoneNumber isKindOfClass:[NSNull class]]) {
              user.phone = phoneNumber;
          }
    }];
    [ZDCChat startChat:nil];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
