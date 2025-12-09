#import "WebIntent.h"
#import <Cordova/CDV.h>

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

    // Parse deep link parameters into dictionary
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    for (NSURLQueryItem *item in components.queryItems) {
        params[item.name] = item.value ?: @"";
    }

    NSDictionary *result = @{
        @"url": url.absoluteString,
        @"data": params
    };

    if (pendingCommand != nil) {
        CDVPluginResult *pluginResult =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];

        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:pendingCommand.callbackId];
    }
}

- (void)getIntent:(CDVInvokedUrlCommand*)command {
    pendingCommand = command;

    // Always keep the callback alive for future deep links
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{}];

    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
