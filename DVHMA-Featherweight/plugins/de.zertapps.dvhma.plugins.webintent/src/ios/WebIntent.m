#import "WebIntent.h"
#import <Cordova/CDV.h>

@interface WebIntent ()
@property (nonatomic, strong) NSDictionary *startupIntent;   // store deep link before JS is ready
@end

@implementation WebIntent {
    CDVInvokedUrlCommand *pendingCommand;
}

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOpenURL:)
                                                 name:CDVPluginHandleOpenURLNotification
                                               object:nil];
}

- (void)handleOpenURL:(NSNotification*)notification {
    NSURL *url = [notification object];
    if (!url) return;

    NSURLComponents *components =
        [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    NSMutableDictionary *extras = [NSMutableDictionary dictionary];

    for (NSURLQueryItem *item in components.queryItems) {
        if (item.name && item.value) {
            extras[item.name] = item.value;
        }
    }

    NSDictionary *result = @{
        @"url": url.absoluteString,
        @"data": extras
    };

    // JS NOT READY YET → cold start
    if (pendingCommand == nil) {
        self.startupIntent = result;
        return;
    }

    // JS READY → send directly
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];

    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:pendingCommand.callbackId];
}

- (void)getIntent:(CDVInvokedUrlCommand*)command {
    pendingCommand = command;

    // If app was opened via deeplink BEFORE JS loaded → send it now
    if (self.startupIntent != nil) {

        CDVPluginResult *pluginResult =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsDictionary:self.startupIntent];

        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        // Consume it so it doesn't fire twice
        self.startupIntent = nil;
        return;
    }

    // No deep link yet → return empty but keep callback alive
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{}];

    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
