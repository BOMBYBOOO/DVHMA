#import "DeepLink.h"
#import <UIKit/UIKit.h>

@implementation UIWindowScene (DeepLinkForwarder)

- (void)scene:(UIScene *)scene
      openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {

    if (URLContexts.count == 0) return;

    NSURL *url = URLContexts.anyObject.URL;
    if (!url) return;

    [[NSNotificationCenter defaultCenter]
        postNotificationName:CDVPluginHandleOpenURLNotification
                      object:url];
}

@end
