#import <Cordova/CDV.h>
#import <sqlite3.h>

@interface DVHMAStorage : CDVPlugin {
    sqlite3 *db;
}
@end

@implementation DVHMAStorage

- (void)pluginInitialize {
    [self openDatabase];
    [self createTableIfNeeded];
}

#pragma mark - SQLite Helpers

- (NSString *)dbPath {
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docs stringByAppendingPathComponent:@"dvhma.db"];
}

- (void)openDatabase {
    if (sqlite3_open([[self dbPath] UTF8String], &db) != SQLITE_OK) {
        NSLog(@"[DVHMAStorage] Failed to open DB");
    }
}

- (void)createTableIfNeeded {
    const char *sql =
        "CREATE TABLE IF NOT EXISTS storage ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title TEXT,"
        "content TEXT"
        ");";

    char *errMsg;
    sqlite3_exec(db, sql, NULL, NULL, &errMsg);
}

#pragma mark - Cordova entry point

- (void)executeSQL:(NSString *)query {
    char *errMsg;
    sqlite3_exec(db, [query UTF8String], NULL, NULL, &errMsg);
}

- (NSArray *)selectAll {
    NSMutableArray *result = [NSMutableArray array];

    const char *sql = "SELECT id,title,content FROM storage;";
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {

            const char *t = (const char *)sqlite3_column_text(stmt, 1);
            const char *c = (const char *)sqlite3_column_text(stmt, 2);

            NSString *title = t ? [NSString stringWithUTF8String:t] : @"";
            NSString *content = c ? [NSString stringWithUTF8String:c] : @"";

            [result addObject:@{
                @"title": title,
                @"content": content
            }];
        }
    }

    sqlite3_finalize(stmt);

    return result;
}

#pragma mark - Plugin methods

- (void)get:(CDVInvokedUrlCommand*)command {
    NSArray *items = [self selectAll];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:items];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)create:(CDVInvokedUrlCommand*)command {

    NSDictionary *obj = [command.arguments objectAtIndex:0];

    NSString *title = obj[@"title"];
    NSString *content = obj[@"content"];

    NSString *sql = [NSString stringWithFormat:
        @"INSERT INTO storage (title,content) VALUES('%@','%@');",
        title, content
    ];

    [self executeSQL:sql];

    // return updated list
    [self get:command];
}

- (void)delete:(CDVInvokedUrlCommand*)command {
    int index = [[command.arguments objectAtIndex:0] intValue];

    NSArray *rows = [self selectAll];
    if (index < 0 || index >= rows.count) {
        CDVPluginResult *error = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Index out of range"];
        [self.commandDelegate sendPluginResult:error callbackId:command.callbackId];
        return;
    }

    // Re-fetch ID by index (same logic as Android plugin)
    NSString *title = rows[index][@"title"];
    NSString *content = rows[index][@"content"];

    NSString *sql = [NSString stringWithFormat:
        @"DELETE FROM storage WHERE title='%@' AND content='%@';",
        title, content
    ];

    [self executeSQL:sql];

    [self get:command];
}

- (void)edit:(CDVInvokedUrlCommand*)command {
    int index = [[command.arguments objectAtIndex:0] intValue];

    NSDictionary *updated = [command.arguments objectAtIndex:1];
    NSString *newTitle = updated[@"title"];
    NSString *newContent = updated[@"content"];

    NSArray *rows = [self selectAll];
    if (index < 0 || index >= rows.count) {
        CDVPluginResult *error = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Index out of range"];
        [self.commandDelegate sendPluginResult:error callbackId:command.callbackId];
        return;
    }

    NSString *oldTitle = rows[index][@"title"];
    NSString *oldContent = rows[index][@"content"];

    NSString *sql = [NSString stringWithFormat:
        @"UPDATE storage SET title='%@', content='%@' WHERE title='%@' AND content='%@';",
        newTitle, newContent, oldTitle, oldContent
    ];

    [self executeSQL:sql];

    [self get:command];
}

@end
