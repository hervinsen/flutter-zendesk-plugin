#import <Flutter/Flutter.h>
#import <ZDCChat/ZDCChat.h>

@interface EventChannelStreamHandler : NSObject <FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;
- (void) send:(NSObject*)event;
@end

@interface ZendeskFlutterPlugin : NSObject<FlutterPlugin>

@property (nonatomic, strong) NSString *accountKey;
@property (nonatomic, strong) ZDCChatAPI *chatApi;

@property (nonatomic, strong) EventChannelStreamHandler *connectionStreamHandler;
@property (nonatomic, strong) EventChannelStreamHandler *accountStreamHandler;
@property (nonatomic, strong) EventChannelStreamHandler *agentsStreamHandler;
@property (nonatomic, strong) EventChannelStreamHandler *chatItemsStreamHandler;

+ (void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end
