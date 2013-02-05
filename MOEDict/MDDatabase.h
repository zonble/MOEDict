#import <Foundation/Foundation.h>

@interface MDDatabase : NSObject

- (id)initWithPath:(NSString *)inPath;
- (void)fetchCompletionListWithString:(NSString *)inStr callback:(void(^)(NSArray *))inCallback;
- (void)fetchDefinitionsWithID:(NSInteger)inID callback:(void(^)(NSDictionary *))inCallback;
- (void)fetchDefinitionsWithKeyword:(NSString *)inKeyword callback:(void(^)(NSDictionary *))inCallback;

@end
