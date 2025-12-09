#import <Cordova/CDV.h>

@interface WebIntent : CDVPlugin
@property (nonatomic, strong) NSDictionary *launchParams;
@end

@implementation WebIntent

- (void)pluginInitialize
{
    // Capture URL parameters if app launched from custom URL scheme
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(onOpenURL:)
               name:CDVPluginHandleOpenURLNotification
             object:nil];
}

- (void)onOpenURL:(NSNotification*)notification
{
    NSURL *url = [notification object];
    self.launchParams = [self parseURL:url];
}

- (NSDictionary *)parseURL:(NSURL*)url
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSString *query = url.query;
    NSArray *parts = [query componentsSeparatedByString:@"&"];

    for (NSString *part in parts) {
        NSArray *pair = [part componentsSeparatedByString:@"="];
        if (pair.count == 2) {
            NSString *key = pair[0];
            NSString *value = pair[1];
            params[key] = value;
        }
    }

    return params;
}

#pragma mark - Cordova execute

- (void)getExtra:(CDVInvokedUrlCommand*)command
{
    NSString *key = [command.arguments objectAtIndex:0];

    // If the app was not launched with an URL → behave like Android
    if (!self.launchParams || self.launchParams.count == 0) {
        CDVPluginResult *res =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                               messageAsString:@"No intent data"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSString *val = self.launchParams[key];

    if (val) {
        CDVPluginResult *res =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:val];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
    } else {
        CDVPluginResult *res =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not found"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
    }
}

@end
