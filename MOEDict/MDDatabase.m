#import "MDDatabase.h"
#import "ObjSqliteDB.h"

NSString *const kMDIdentifierKey = @"id";
NSString *const kMDTitleKey = @"title";
NSString *const kMDRadicalKey = @"radical";
NSString *const kMDStrokeCountKey = @"stroke_count";
NSString *const kMDNonRadicalStrokeCountKey = @"non_radical_stroke_count";
NSString *const kMDBHeteronymsKey = @"heteronyms";
NSString *const kMDBopomofo1Key = @"bopomofo";
NSString *const kMDBopomofo2Key = @"bopomofo2";
NSString *const kMDPinyinKey = @"pinyin";
NSString *const kMDDefinitionsKey = @"definitions";
NSString *const kMDBTypeKey = @"type";
NSString *const kMDDefinitionKey = @"definition";
NSString *const kMDExcampleKey = @"example";
NSString *const kMDSynonymsKey = @"synonyms";
NSString *const kMDAntonymsKey = @"antonyms";
NSString *const kMDSourceKey = @"source";
NSString *const kMDQuoteKey = @"quote";
NSString *const kMDLinkKey = @"link";

@implementation MDDatabase
{
	ObjSqliteDB *db;
	NSOperationQueue *operationQueue;
}

- (void)dealloc
{
	[db release];
	[operationQueue release];
	[super dealloc];
}

- (id)initWithPath:(NSString *)inPath
{
	self = [super init];
	if (self) {
		db = [[ObjSqliteDB alloc] initWithPath:inPath];
		NSAssert(db != nil, @"Database must be created.");
		__unused sqlite3 *ObjSqliteDB = db.sqliteDB;
		NSAssert(ObjSqliteDB != nil, @"Database must be created.");
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void)_fetchCompletionListWithString:(NSString *)inStr callback:(void (^)(NSArray *))inCallback
{
	if (!inStr || ![inStr length]) {
		return;
	}

	const char *SQL = "SELECT id,title FROM entries WHERE title LIKE ? || '%';";
	ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:SQL db:db];
	[statement bindText:inStr toColumn:1];
	NSMutableArray *list = [NSMutableArray array];
	while ([statement step]) {
		NSInteger entryID = [statement intFromColumn:0];
		NSString *title = [statement textFromColumn:1];
		if (entryID) {
			[list addObject:@{kMDIdentifierKey: @(entryID), kMDTitleKey: title}];
		}
	}
	[statement release];
	dispatch_async(dispatch_get_main_queue(), ^{
		inCallback(list);
	});
}

- (void)fetchCompletionListWithString:(NSString *)inStr callback:(void (^)(NSArray *))inCallback
{
	if (!inStr || ![inStr length]) {
		return;
	}

	NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
		[self _fetchCompletionListWithString:inStr callback:inCallback];
	}];
	[operationQueue cancelAllOperations];
	[operationQueue addOperation:op];
}

- (void)_fetchDefinitionsWithID:(NSInteger)inEntryID callback:(void (^)(NSDictionary *))inCallback;
{
	NSMutableDictionary *response = [NSMutableDictionary dictionary];

	const char *SQL = "SELECT title, radical, stroke_count, non_radical_stroke_count FROM entries WHERE id = ?";
	ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:SQL db:db];
	[statement bindInt:inEntryID toColumn:1];
	[statement step];
	NSString *title = [statement textFromColumn:0];
	NSString *radical = [statement textFromColumn:1];
	NSString *strokeCount = [statement textFromColumn:2];
	NSString *nonRadicalStrokeCount = [statement textFromColumn:3];
	if (title) {
		response[kMDTitleKey] = title;
	}
	if (radical) {
		response[kMDRadicalKey] = radical;
	}
	if (strokeCount) {
		response[kMDStrokeCountKey] = [NSDecimalNumber decimalNumberWithString:strokeCount];
	}
	if (nonRadicalStrokeCount) {
		response[kMDNonRadicalStrokeCountKey] = [NSDecimalNumber decimalNumberWithString:nonRadicalStrokeCount];
	}

	const char *heteronymSQL = "SELECT id, bopomofo, bopomofo2, pinyin FROM heteronyms WHERE entry_id = ?";
	ObjSqliteStatement *heteronymStatement = [[ObjSqliteStatement alloc] initWithSQL:heteronymSQL db:db];
	[heteronymStatement bindInt:inEntryID toColumn:1];
	NSMutableArray *list = [NSMutableArray array];
	while ([heteronymStatement step]) {
		NSInteger heteronymID = [heteronymStatement intFromColumn:0];
		NSString *bopomofo = [heteronymStatement textFromColumn:1];
		NSString *bopomofo2 = [heteronymStatement textFromColumn:2];
		NSString *pinyin = [heteronymStatement textFromColumn:3];
		if (heteronymID) {
			NSMutableDictionary *d = [NSMutableDictionary dictionary];
			d[kMDIdentifierKey] = @(heteronymID);
			if (bopomofo) {
				d[kMDBopomofo1Key] = bopomofo;
			}
			if (bopomofo2) {
				d[kMDBopomofo2Key] = bopomofo2;
			}
			if (pinyin) {
				d[kMDPinyinKey] = pinyin;
			}
			[list addObject:d];
		}
	}
	[heteronymStatement release];

	for (NSMutableDictionary *heteronym in list) {
		NSInteger heteronymID = [heteronym[kMDIdentifierKey] integerValue];
		const char *definitionSQL = "SELECT id, type, def, example, synonyms, antonyms, source, quote, link FROM definitions WHERE heteronym_id = ?";
		ObjSqliteStatement *definitionStatement = [[ObjSqliteStatement alloc] initWithSQL:definitionSQL db:db];
		[definitionStatement bindInt:heteronymID toColumn:1];
		NSMutableArray *definitions = [NSMutableArray array];
		while ([definitionStatement step]) {
			NSInteger definitionID = [definitionStatement intFromColumn:0];
			NSString *typeString = [definitionStatement textFromColumn:1];
			NSString *definition = [definitionStatement textFromColumn:2];
			NSString *example = [definitionStatement textFromColumn:3];
			NSString *synonyms = [definitionStatement textFromColumn:4];
			NSString *antonyms = [definitionStatement textFromColumn:5];
			NSString *source = [definitionStatement textFromColumn:6];
			NSString *quote = [definitionStatement textFromColumn:7];
			NSString *link = [definitionStatement textFromColumn:8];
			if (definitionID) {
				NSMutableDictionary *d = [NSMutableDictionary dictionary];
				if (typeString) {
					d[@"type"] = typeString;
				}
				if (definition) {
					d[kMDDefinitionKey] = definition;
				}
				if (example) {
					d[kMDExcampleKey] = example;
				}
				if (source) {
					d[kMDSourceKey] = source;
				}
				if (link) {
					d[kMDLinkKey] = link;
				}
				if (synonyms) {
					d[kMDSynonymsKey] = [synonyms componentsSeparatedByString:@","];
				}
				if (antonyms) {
					d[kMDAntonymsKey] = [antonyms componentsSeparatedByString:@","];
				}
				if (quote) {
					d[kMDQuoteKey] = [quote componentsSeparatedByString:@","];
				}
				[definitions addObject:d];
			}
		}
		[definitionStatement release];
		heteronym[kMDDefinitionsKey] = definitions;
	}
	response[kMDBHeteronymsKey] = list;
	dispatch_async(dispatch_get_main_queue(), ^{
		inCallback(response);
	});
}

- (void)fetchDefinitionsWithID:(NSInteger)inEntryID callback:(void (^)(NSDictionary *))inCallback
{
	NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
		[self _fetchDefinitionsWithID:inEntryID callback:inCallback];
	}];
	[operationQueue cancelAllOperations];
	[operationQueue addOperation:op];
}

- (NSInteger)_entryIDWithKeyword:(NSString *)inKeyword
{
	const char *SQL = "SELECT id,title FROM entries WHERE title = ?";
	ObjSqliteStatement *statement = [[[ObjSqliteStatement alloc] initWithSQL:SQL db:db] autorelease];
	[statement bindText:inKeyword toColumn:1];
	[statement step];
	NSInteger index = [statement intFromColumn:0];
	if (index) {
		__unused NSString *title = [statement textFromColumn:1];
		NSAssert([title isEqualToString:inKeyword], @"Keyword must match.");
	}
	return index;
}

- (void)fetchDefinitionsWithKeyword:(NSString *)inKeyword callback:(void (^)(NSDictionary *))inCallback
{
	if (!inKeyword || ![inKeyword length]) {
		return;
	}

	NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
		NSInteger entryID = [self _entryIDWithKeyword:inKeyword];
		if (entryID) {
			[self _fetchDefinitionsWithID:entryID callback:inCallback];
		}
	}];
	[operationQueue cancelAllOperations];
	[operationQueue addOperation:op];
}

@end
