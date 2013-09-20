#import "MDDatabase.h"
#import "ObjSqliteDB.h"
#import "ObjSqliteStatement.h"

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
		__unused sqlite3* ObjSqliteDB = db.sqliteDB;
		NSAssert(ObjSqliteDB != nil, @"Database must be created.");
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void)_fetchCompletionListWithString:(NSString *)inStr callback:(void(^)(NSArray *))inCallback
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
			[list addObject:@{kMDIdentifierKey:@(entryID), kMDTitleKey:title}];
		}
	}
	[statement release];
	dispatch_async(dispatch_get_main_queue(), ^{
		inCallback(list);
	});
}

- (void)fetchCompletionListWithString:(NSString *)inStr callback:(void(^)(NSArray *))inCallback
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

- (void)_fetchDefinitionsWithID:(NSInteger)inEntryID callback:(void(^)(NSDictionary *))inCallback;
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
	if (title) { [response setObject:title forKey:kMDTitleKey]; }
	if (radical) { [response setObject:radical forKey:kMDRadicalKey]; }
	if (strokeCount) {
		[response setObject:[NSDecimalNumber decimalNumberWithString:strokeCount] forKey:kMDStrokeCountKey];
	}
	if (nonRadicalStrokeCount) {
		[response setObject:[NSDecimalNumber decimalNumberWithString:nonRadicalStrokeCount] forKey:kMDNonRadicalStrokeCountKey];
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
			[d setObject:@(heteronymID) forKey:kMDIdentifierKey];
			if (bopomofo) { [d setObject:bopomofo forKey:kMDBopomofo1Key]; }
			if (bopomofo2) { [d setObject:bopomofo2 forKey:kMDBopomofo2Key]; }
			if (pinyin) { [d setObject:pinyin forKey:kMDPinyinKey]; }
			[list addObject:d];
		}
	}
	[heteronymStatement release];

	for (NSMutableDictionary *heteronym in list) {
		NSInteger heteronymID = [[heteronym objectForKey:kMDIdentifierKey] integerValue];
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
				if (typeString) { [d setObject:typeString forKey:@"type"]; }
				if (definition) { [d setObject:definition forKey:kMDDefinitionKey]; }
				if (example) { [d setObject:example forKey:kMDExcampleKey]; }
				if (source) { [d setObject:source forKey:kMDSourceKey]; }
				if (link) { [d setObject:link forKey:kMDLinkKey]; }
				if (synonyms) {
					[d setObject:[synonyms componentsSeparatedByString:@","] forKey:kMDSynonymsKey];
				}
				if (antonyms) {
					[d setObject:[antonyms componentsSeparatedByString:@","] forKey:kMDAntonymsKey];
				}
				if (quote) {
					[d setObject:[quote componentsSeparatedByString:@","] forKey:kMDQuoteKey];
				}
				[definitions addObject:d];
			}
		}
		[definitionStatement release];
		[heteronym setObject:definitions forKey:kMDDefinitionsKey];
	}
	[response setObject:list forKey:kMDBHeteronymsKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		inCallback(response);
	});
}

- (void)fetchDefinitionsWithID:(NSInteger)inEntryID callback:(void(^)(NSDictionary *))inCallback
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
	ObjSqliteStatement *statement = [[ObjSqliteStatement alloc] initWithSQL:SQL db:db];
	[statement bindText:inKeyword toColumn:1];
	[statement step];
	NSInteger index = [statement intFromColumn:0];
	if (index) {
		__unused NSString *title = [statement textFromColumn:1];
		NSAssert([title isEqualToString:inKeyword], @"Keyword must match.");
	}
	return index;
}

- (void)fetchDefinitionsWithKeyword:(NSString *)inKeyword callback:(void(^)(NSDictionary *))inCallback
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
