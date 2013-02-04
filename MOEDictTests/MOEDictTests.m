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

	__block BOOL done = NO;

	[db fetchCompletionListWithString:@"萌" callback:^(NSArray *list) {
		NSLog(@"list:%@", list);
		for (NSDictionary *d in list) {
			STAssertNotNil(d[@"id"], @"ID must not be nil");
			STAssertTrue([d[@"id"] integerValue] > 0, @"ID must not be nil");
			STAssertNotNil(d[@"title"], @"Title must not be nil");
			STAssertTrue([d[@"title"] length], @"There must be a title");
		}
		done = YES;
	}];

	while (!done) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
	[db release];
}

- (void)testFetchDefinition
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"db" ofType:@"sqlite3"];
	MDDatabase *db = [[MDDatabase alloc] initWithPath:path];

	__block BOOL done = NO;

	[db fetchDefinitionsWithID:18979 callback:^(NSDictionary *list) {
		NSLog(@"list:%@", list);
		done = YES;
	}];

	while (!done) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}
//

@end
