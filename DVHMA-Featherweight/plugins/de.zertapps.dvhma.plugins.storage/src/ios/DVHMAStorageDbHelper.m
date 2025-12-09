#import "DVHMAStorageDbHelper.h"
#import <sqlite3.h>

@implementation DVHMAStorageDbHelper {
    sqlite3 *_db;
}

static NSString * const kDBName = @"Todos.db";
static NSString * const kTableName = @"todos";

- (NSString*)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths firstObject];
    return [documents stringByAppendingPathComponent:kDBName];
}

- (BOOL)openDatabase {
    NSString *path = [self databasePath];
    int rc = sqlite3_open([path UTF8String], &_db);
    if (rc != SQLITE_OK) {
        NSLog(@"DVHMAStorageDbHelper: could not open DB at %@ (rc=%d)", path, rc);
        return NO;
    }

    const char *createSql = "CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT)";
    char *err = NULL;
    if (sqlite3_exec(_db, createSql, NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"DVHMAStorageDbHelper: create table failed: %s", err);
        if (err) sqlite3_free(err);
        return NO;
    }

    return YES;
}

- (NSArray *)queryAll {
    NSMutableArray *ret = [NSMutableArray array];
    const char *sql = "SELECT id, title, content FROM todos ORDER BY id ASC";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int rid = sqlite3_column_int(stmt, 0);

            const unsigned char *t = sqlite3_column_text(stmt, 1);
            const unsigned char *c = sqlite3_column_text(stmt, 2);

            NSString *title = t ? [NSString stringWithUTF8String:(const char *)t] : @"";
            NSString *content = c ? [NSString stringWithUTF8String:(const char *)c] : @"";

            NSDictionary *row = @{ @"id": @(rid), @"title": title, @"content": content };
            [ret addObject:row];
        }
    } else {
        NSLog(@"DVHMAStorageDbHelper: prepare query failed");
    }
    if (stmt) sqlite3_finalize(stmt);
    return [ret copy];
}

- (BOOL)insertTitle:(NSString*)title content:(NSString*)content {
    const char *sql = "INSERT INTO todos (title, content) VALUES (?, ?)";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        if (stmt) sqlite3_finalize(stmt);
        return NO;
    }
    sqlite3_bind_text(stmt, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [content UTF8String], -1, SQLITE_TRANSIENT);

    int rc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return (rc == SQLITE_DONE);
}

- (BOOL)updateId:(int)rowId title:(NSString*)title content:(NSString*)content {
    const char *sql = "UPDATE todos SET title = ?, content = ? WHERE id = ?";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        if (stmt) sqlite3_finalize(stmt);
        return NO;
    }
    sqlite3_bind_text(stmt, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [content UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 3, rowId);

    int rc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return (rc == SQLITE_DONE);
}

- (BOOL)deleteId:(int)rowId {
    const char *sql = "DELETE FROM todos WHERE id = ?";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        if (stmt) sqlite3_finalize(stmt);
        return NO;
    }
    sqlite3_bind_int(stmt, 1, rowId);
    int rc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return (rc == SQLITE_DONE);
}

@end
