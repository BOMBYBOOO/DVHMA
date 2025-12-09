#import <Cordova/CDV.h>

@interface DeepLink : CDVPlugin

// This is the JS-exposed method
- (void)listen:(CDVInvokedUrlCommand *)command;

@end
