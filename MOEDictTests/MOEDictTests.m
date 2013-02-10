#import "MOEDictTests.h"
#import "MDDatabase.h"

@implementation MOEDictTests
- (void)setUp
{
    [super setUp];
}
- (void)tearDown
{
    [super tearDown];
}
- (void)testFetchPrefix
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"db" ofType:@"sqlite3"];
	MDDatabase *db = [[MDDatabase alloc] initWithPath:path];

	void (^b)(NSString*) = ^(NSString *s) {
	__block BOOL done = NO;
		[db fetchCompletionListWithString:s callback:^(NSArray *list) {
			for (NSDictionary *d in list) {
				STAssertNotNil(d[kMDIdentifierKey], @"ID must not be nil");
				STAssertTrue([d[kMDIdentifierKey] integerValue] > 0, @"ID must not be nil");
				STAssertNotNil(d[kMDTitleKey], @"Title must not be nil");
				STAssertTrue([d[kMDTitleKey] length], @"There must be a title");
			}
			done = YES;
		}];
		while (!done) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
	};
	for (NSString *s in @[@"萌", @"中", @"文", @"字", @"典"]) {
		b(s);
	}
	[db release];
}

- (void)_validateDefinition:(NSDictionary *)d
{
	STAssertNotNil([d objectForKey:kMDTitleKey], @"Title must not be nil.");
	if ([d objectForKey:kMDBopomofo1Key]) {
		STAssertTrue([[d objectForKey:kMDBopomofo1Key] length], @"Length of bopomofo1 must be larger than 0");
	}
	if ([d objectForKey:kMDBopomofo2Key]) {
		STAssertTrue([[d objectForKey:kMDBopomofo2Key] length], @"Length of bopomofo2 must be larger than 0.");
	}
	if ([d objectForKey:kMDPinyinKey]) {
		STAssertTrue([[d objectForKey:kMDPinyinKey] length], @"Length of pinyin must be larger than 0 ");
	}
	STAssertNotNil([d objectForKey:kMDBHeteronymsKey], @"kMDBHeteronymsKey must not be nil");
	STAssertTrue([[d objectForKey:kMDBHeteronymsKey] count], @"There must be at least one heteronym ");
	for (NSDictionary *heteronym in [d objectForKey:kMDBHeteronymsKey]) {
		if ([heteronym objectForKey:kMDSynonymsKey]) {
			STAssertTrue([[heteronym objectForKey:kMDSynonymsKey] count], @"Length of kMDSynonymsKey must be larger than 0");
		}
		if ([heteronym objectForKey:kMDAntonymsKey]) {
			STAssertTrue([[heteronym objectForKey:kMDAntonymsKey] count], @"Length of kMDAntonymsKey must be larger than 0");
		}
		if ([heteronym objectForKey:kMDQuoteKey]) {
			STAssertTrue([[heteronym objectForKey:kMDQuoteKey] count], @"Length of kMDAntonymsKey must be larger than 0");
		}
	}
}

- (void)testFetchDefinition
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"db" ofType:@"sqlite3"];
	MDDatabase *db = [[MDDatabase alloc] initWithPath:path];

	__block BOOL done = NO;

	[db fetchDefinitionsWithID:18979 callback:^(NSDictionary *d) {
		[self _validateDefinition:d];
		done = YES;
	}];

	while (!done) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}
//

@end
