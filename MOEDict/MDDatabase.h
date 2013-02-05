#import <Foundation/Foundation.h>

extern NSString *const kMDIdentifierKey;
extern NSString *const kMDTitleKey;
extern NSString *const kMDRadicalKey;
extern NSString *const kMDStrokeCountKey;
extern NSString *const kMDNonRadicalStrokeCountKey;
extern NSString *const kMDBHeteronymsKey;
extern NSString *const kMDBopomofo1Key;
extern NSString *const kMDBopomofo2Key;
extern NSString *const kMDBPinyinKey;
extern NSString *const kMDBDefinitionsKey;
extern NSString *const kMDBTypeKey;
extern NSString *const kMDBDefinitionKey;
extern NSString *const kMDBExcampleKey;
extern NSString *const kMDBSynonymsKey;
extern NSString *const kMDBAntonymsKey;
extern NSString *const kMDBSourceKey;

// An interface which helps search with the database of MOE
// Dictionary.

@interface MDDatabase : NSObject

- (id)initWithPath:(NSString *)inPath; // Path of the database file.

- (void)fetchCompletionListWithString:(NSString *)inStr callback:(void(^)(NSArray *))inCallback;
- (void)fetchDefinitionsWithID:(NSInteger)inID callback:(void(^)(NSDictionary *))inCallback;
- (void)fetchDefinitionsWithKeyword:(NSString *)inKeyword callback:(void(^)(NSDictionary *))inCallback;

@end
