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

    // If the app was launched via a deep link → deliver it
    NSString *initialURL =
        [[NSUserDefaults standardUserDefaults] stringForKey:@"initialLaunchURL"];

    if (initialURL && callback) {
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                               messageAsString:initialURL];
        [result setKeepCallback:@YES];
        [self.commandDelegate sendPluginResult:result callbackId:callback.callbackId];
    }
}

- (void)listen:(CDVInvokedUrlCommand *)command {
    callback = command;

    // Send “listening” acknowledgment
    CDVPluginResult *r =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                         messageAsString:@"listening"];
    [r setKeepCallback:@YES];
    [self.commandDelegate sendPluginResult:r callbackId:command.callbackId];

    // After listener attaches → deliver initial deep link if exists
    NSString *initialURL =
        [[NSUserDefaults standardUserDefaults] stringForKey:@"initialLaunchURL"];

    if (initialURL) {
        CDVPluginResult *result =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                               messageAsString:initialURL];
        [result setKeepCallback:@YES];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

        // clear after sending once
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"initialLaunchURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
