/*! A class which renders character or phrase definitions into HTML
format. */

@interface MDHTMLRenderer : NSObject

- (NSString *)renderHTML:(NSDictionary *)inDictionary;

@end
