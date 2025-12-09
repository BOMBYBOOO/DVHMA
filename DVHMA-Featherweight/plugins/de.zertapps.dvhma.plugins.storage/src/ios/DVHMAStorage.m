#import "DVHMAStorage.h"
#import "DVHMAStorageDbHelper.h"

@implementation DVHMAStorage {
    DVHMAStorageDbHelper *_dbHelper;
}

- (void)pluginInitialize {
    [super pluginInitialize];
    _dbHelper = [[DVHMAStorageDbHelper alloc] init];
    [_dbHelper openDatabase]; // ensure DB/table exists
}

- (void)create:(CDVInvokedUrlCommand*)command {
    NSLog(@"[Storage] create called with args: %@", command.arguments);
    NSDictionary *obj = [command.arguments firstObject];
    NSString *title = obj[@"title"] ?: @"";
    NSString *content = obj[@"content"] ?: @"";

    BOOL ok = [_dbHelper insertTitle:title content:content];
    if (!ok) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"insert_failed"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSArray *all = [_dbHelper queryAll];
    CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:all];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)get:(CDVInvokedUrlCommand*)command {
    NSLog(@"[Storage] get called");
    NSArray *all = [_dbHelper queryAll];
    CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:all];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)edit:(CDVInvokedUrlCommand*)command {
    // Android plugin expects index (int) then object {title,content}
    NSLog(@"[Storage] edit called: %@", command.arguments);
    if (command.arguments.count < 2) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid_args"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSNumber *indexNum = command.arguments[0];
    NSDictionary *obj = command.arguments[1];
    NSString *title = obj[@"title"] ?: @"";
    NSString *content = obj[@"content"] ?: @"";

    // Android plugin used index as position in result set; replicate that behaviour:
    NSArray *rows = [_dbHelper queryAll];
    NSInteger idx = [indexNum integerValue];
    if (idx < 0 || idx >= rows.count) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"index_out_of_bounds"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // rows are dictionaries with "id" key
    NSNumber *rowId = rows[idx][@"id"];
    BOOL ok = [_dbHelper updateId:[rowId intValue] title:title content:content];
    if (!ok) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"update_failed"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSArray *all = [_dbHelper queryAll];
    CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:all];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)delete:(CDVInvokedUrlCommand*)command {
    NSLog(@"[Storage] delete called for ID: %@", ID);
    if (command.arguments.count < 1) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"invalid_args"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSNumber *indexNum = command.arguments[0];
    NSArray *rows = [_dbHelper queryAll];
    NSInteger idx = [indexNum integerValue];
    if (idx < 0 || idx >= rows.count) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"index_out_of_bounds"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSNumber *rowId = rows[idx][@"id"];
    BOOL ok = [_dbHelper deleteId:[rowId intValue]];
    if (!ok) {
        CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"delete_failed"];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    NSArray *all = [_dbHelper queryAll];
    CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:all];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

@end
