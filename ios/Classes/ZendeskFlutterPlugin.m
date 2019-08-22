#import "ZendeskFlutterPlugin.h"
#import "ChatStyling.h"
#import "ViewController.h"

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
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.2431f green:0.8588f blue:0.7098f alpha:1]];
    // [[UINavigationBar appearance] setTitleTextAttributes:navbarAttributes];
    [ChatStyling applyStyling];
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
    [ZDCChat startChat:^(ZDCConfig *config) {
      config.preChatDataRequirements.department = ZDCPreChatDataRequiredEditable;
      config.preChatDataRequirements.message = ZDCPreChatDataRequired;
    }];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
