#import <Foundation/Foundation.h>

@interface DVHMAStorageDbHelper : NSObject

- (BOOL)openDatabase;
- (NSArray *)queryAll; // returns array of dictionaries: { "id": NSNumber, "title": NSString, "content": NSString }
- (BOOL)insertTitle:(NSString*)title content:(NSString*)content;
- (BOOL)updateId:(int)rowId title:(NSString*)title content:(NSString*)content;
- (BOOL)deleteId:(int)rowId;

@end
