#import "MDDatabase.h"
#import "MDHTMLRenderer.h"

/*! The main view controller for iPhone/iPod Touch. */
@interface MDViewController : UIViewController
	<UITableViewDataSource,
	UITableViewDelegate,
	UISearchBarDelegate,
	UIWebViewDelegate>

- (void)searchWithKeyword:(NSString *)inKeyword;

@property (retain, nonatomic) MDDatabase *db;
@property (retain, nonatomic) MDHTMLRenderer *HTMLRenderer;
@property (retain, nonatomic) NSArray *prefixArray;
@property (retain, nonatomic) UIWebView *webView;
@property (retain, nonatomic) UISearchBar *searchBar;
@end
