#import "MDHTMLRenderer.h"
#import "MDDatabase.h"

@interface MDHTMLRenderer ()
@property (retain, nonatomic) NSString *CSS;
@end

@implementation MDHTMLRenderer

- (void)dealloc
{
	[_CSS release];
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		NSString *path = [[NSBundle mainBundle] pathForResource:IsIPad() ? @"style_ipad" : @"style" ofType:@"css"];
		_CSS = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:NSUTF8StringEncoding error:nil];
	}
	return self;
}

- (NSString *)renderHTML:(NSDictionary *)inDictionary
{
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"<html><head><style>%@</style></head><body>", self.CSS];
	if (inDictionary[kMDTitleKey]) {
		[s appendFormat:@"<h1 class=\"%@\">%@</h1>",
		 (inDictionary[kMDRadicalKey] || inDictionary[kMDStrokeCountKey] || inDictionary[kMDNonRadicalStrokeCountKey]) ? @"char_title" : @"phrase_title",
			inDictionary[kMDTitleKey]];
	}
	if (inDictionary[kMDRadicalKey] || inDictionary[kMDStrokeCountKey] || inDictionary[kMDNonRadicalStrokeCountKey]) {
		[s appendString:@"<div class=\"char_info\">"];
		[s appendString:@"<ul>"];
		if (inDictionary[kMDRadicalKey]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Radical:", @""), inDictionary[kMDRadicalKey]];
		}
		if (inDictionary[kMDStrokeCountKey]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Stroke Count:", @""), inDictionary[kMDStrokeCountKey]];
		}
		if (inDictionary[kMDNonRadicalStrokeCountKey]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Stroke Count besides Radical:", @""), inDictionary[kMDNonRadicalStrokeCountKey]];
		}
		[s appendString:@"</ul>"];
		[s appendString:@"</div>"];
	}

	[s appendString:@"<br clear=\"all\">"];

	for (NSDictionary *heteronym in inDictionary[kMDBHeteronymsKey]) {
		[s appendString:@"<div class=\"heteronym\">"];
		[s appendString:@"<ul>"];
		if (heteronym[kMDBopomofo1Key]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Phonetic 1:", @""), heteronym[kMDBopomofo1Key]];
		}
		if (heteronym[kMDBopomofo2Key]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Phonetic 2:", @""), heteronym[kMDBopomofo2Key]];
		}
		if (heteronym[kMDBPinyinKey]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Hanyu Pinyin:", @""), heteronym[kMDBPinyinKey]];
		}
		[s appendString:@"</ul>"];
		for (NSDictionary *definition in heteronym[kMDBDefinitionsKey]) {
			if (definition[kMDBTypeKey]) {
				[s appendFormat:@"<p><b>[%@]</b> %@</p>", definition[kMDBTypeKey], definition[kMDBDefinitionKey]];
			}
			else {
				[s appendFormat:@"<p>%@</p>", definition[kMDBDefinitionKey]];
			}

			if (definition[kMDBExcampleKey]) {
				[s appendFormat:@"<p>%@ %@</p>", NSLocalizedString(@"Sample:", @""), definition[kMDBExcampleKey]];
			}
			if (definition[kMDBSynonymsKey]) {
			}
			if (definition[kMDBAntonymsKey]) {
			}
			if (definition[kMDBSourceKey]) {
			}
		}
		[s appendString:@"</div>"];
	}

	[s appendString:@"</body></html>"];
	return s;
}

@end
