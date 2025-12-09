#import "DeepLink.h"
#import <Cordova/CDV.h>

@implementation DeepLink {
    CDVInvokedUrlCommand *callback;
}

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onOpenURL:)
                                                 name:CDVPluginHandleOpenURLNotification
                                               object:nil];

    // Check if Cordova already stored an initial URL
    NSString *storedURL = [self.commandDelegate.settings objectForKey:@"url"];
    if (storedURL && callback) {
        CDVPluginResult *result =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsString:storedURL];
        [result setKeepCallback:@YES];
        [self.commandDelegate sendPluginResult:result callbackId:callback.callbackId];
    }
}


- (void)listen:(CDVInvokedUrlCommand *)command {
    callback = command;

    CDVPluginResult *r =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                       messageAsString:@"listening"];
    [r setKeepCallback:@YES];
    [self.commandDelegate sendPluginResult:r callbackId:command.callbackId];
}

- (void)onOpenURL:(NSNotification*)n {
    if (!callback) return;

    NSURL *url = [n object];
    if (!url) return;

    CDVPluginResult *result =
      [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                       messageAsString:url.absoluteString];

    [result setKeepCallback:@YES];
    [self.commandDelegate sendPluginResult:result callbackId:callback.callbackId];
}

@end
