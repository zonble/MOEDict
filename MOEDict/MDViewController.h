#import "MDDatabase.h"

@interface MDViewController : UIViewController
	<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (retain, nonatomic) MDDatabase *db;
@property (retain, nonatomic) NSArray *prefixArray;
@property (retain, nonatomic) UISearchDisplayController *searchDisplayController;
@property (retain, nonatomic) UIWebView *webView;
@property (retain, nonatomic) UISearchBar *searchBar;

@end
