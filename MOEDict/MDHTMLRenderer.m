#import "MDHTMLRenderer.h"
#import "MDDatabase.h"

@implementation MDHTMLRenderer

- (NSString *)renderHTML:(NSDictionary *)inDictionary
{
	NSMutableString *s = [NSMutableString string];
	[s appendString:@"<html><head></head><body>"];
	if (inDictionary[kMDTitleKey]) {
		[s appendFormat:@"<h1>%@</h1>", inDictionary[kMDTitleKey]];
	}
	[s appendString:@"<div>"];
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

	for (NSDictionary *heteronym in inDictionary[kMDBHeteronymsKey]) {
		[s appendString:@"<div>"];
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
