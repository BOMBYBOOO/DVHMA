#import "DeepLink.h"
#import <UIKit/UIKit.h>

@implementation UIWindowScene (DeepLinkForwarder)

- (void)scene:(UIScene *)scene
      openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {

    if (URLContexts.count == 0) return;

    NSURL *url = URLContexts.anyObject.URL;
    if (!url) return;

    // Store URL for Cordova to read later
    [[NSUserDefaults standardUserDefaults] setObject:url.absoluteString
                                              forKey:@"initialLaunchURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Forward into Cordova plugin system
    [[NSNotificationCenter defaultCenter]
        postNotificationName:CDVPluginHandleOpenURLNotification
                      object:url];
}

@end
