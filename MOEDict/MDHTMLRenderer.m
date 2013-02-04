#import "MDHTMLRenderer.h"

@implementation MDHTMLRenderer

- (NSString *)renderHTML:(NSDictionary *)inDictionary
{
	NSMutableString *s = [NSMutableString string];
	[s appendString:@"<html><head></head><body>"];
	if (inDictionary[@"title"]) {
		[s appendFormat:@"<h1>%@</h1>", inDictionary[@"title"]];
	}
	[s appendString:@"<div>"];
	[s appendString:@"<ul>"];
	if (inDictionary[@"radical"]) {
		[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Radical:", @""), inDictionary[@"radical"]];
	}
	if (inDictionary[@"stroke_count"]) {
		[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Stroke Count:", @""), inDictionary[@"stroke_count"]];
	}
	if (inDictionary[@"non_radical_stroke_count"]) {
		[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Stroke Count besides Radical:", @""), inDictionary[@"non_radical_stroke_count"]];
	}
	[s appendString:@"</ul>"];
	[s appendString:@"</div>"];

	for (NSDictionary *heteronym in inDictionary[@"heteronyms"]) {
		[s appendString:@"<div>"];
		[s appendString:@"<ul>"];
		if (heteronym[@"bopomofo"]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Phonetic 1:", @""), heteronym[@"bopomofo"]];
		}
		if (heteronym[@"bopomofo2"]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Phonetic 2:", @""), heteronym[@"bopomofo2"]];
		}
		if (heteronym[@"pinyin"]) {
			[s appendFormat:@"<li>%@ <b>%@</b></li>", NSLocalizedString(@"Hanyu Pinyin:", @""), heteronym[@"pinyin"]];
		}
		[s appendString:@"</ul>"];
		for (NSDictionary *definition in heteronym[@"definitions"]) {
			if (definition[@"type"]) {
				[s appendFormat:@"<p><b>[%@]</b> %@</p>", definition[@"type"], definition[@"definition"]];
			}
			else {
				[s appendFormat:@"<p>%@</p>", definition[@"definition"]];
			}

			if (definition[@"example"]) {
				[s appendFormat:@"<p>%@ %@</p>", NSLocalizedString(@"Sample:", @""), definition[@"example"]];
			}
			if (definition[@"synonyms"]) {
			}
			if (definition[@"antonyms"]) {
			}
			if (definition[@"source"]) {
			}
		}
		[s appendString:@"</div>"];
	}

	[s appendString:@"</body></html>"];
	return s;
}

@end
