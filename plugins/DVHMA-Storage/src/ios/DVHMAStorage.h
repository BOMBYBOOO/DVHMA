#import <Cordova/CDV.h>

@interface DVHMAStorage : CDVPlugin

- (void)create:(CDVInvokedUrlCommand*)command;
- (void)get:(CDVInvokedUrlCommand*)command;
- (void)edit:(CDVInvokedUrlCommand*)command;
- (void)delete:(CDVInvokedUrlCommand*)command;

@end
