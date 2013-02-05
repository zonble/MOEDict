#import "MDIPadViewController.h"

@interface MDIPadMainView : UIView
@property (assign, nonatomic) UIView *leftView;
@property (assign, nonatomic) UIView *rightView;
@end

@implementation MDIPadMainView

- (void)layoutSubviews
{
	CGSize size = self.bounds.size;
	CGFloat w = (size.width > size.height) ? 320 : 260;
	self.leftView.frame = CGRectMake(0.0, 0.0, w - 1, self.bounds.size.height);
	self.rightView.frame = CGRectMake(w, 0.0, self.bounds.size.width - w, self.bounds.size.height);
	if (!self.leftView.superview) {
		[self addSubview:self.leftView];
	}
	if (!self.rightView.superview) {
		[self addSubview:self.rightView];
	}
}

@end

@interface MDIPadViewController ()
@property (retain, nonatomic) UIView *leftView;
@property (retain, nonatomic) UITableView *tableView;
@end

@implementation MDIPadViewController

- (void)loadView
{
	self.view = [[[MDIPadMainView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width - 320.0, self.view.bounds.size.height)] autorelease];
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	self.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height)] autorelease];;

	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
	self.searchBar.delegate = self;
	self.searchBar.placeholder = NSLocalizedString(@"Your Keyword", @"");
	self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	[self.leftView addSubview:self.searchBar];

	self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, self.view.bounds.size.height - 44.0) style:UITableViewStylePlain] autorelease];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[self.leftView addSubview:self.tableView];

	[(MDIPadMainView *)self.view setLeftView:self.leftView];
	[(MDIPadMainView *)self.view setRightView:self.webView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *d = [self.prefixArray objectAtIndex:indexPath.row];
	NSInteger entryID = [[d objectForKey:@"id"] integerValue];
	self.searchBar.text = [d objectForKey:@"title"];
	[self.db fetchDefinitionsWithID:entryID callback:^(NSDictionary *response) {
		NSString *HTML = [self.HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
		[self.searchBar resignFirstResponder];
	}];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([text length]) {
		[self.db fetchDefinitionsWithKeyword:text callback:^(NSDictionary *response) {
			NSString *HTML = [self.HTMLRenderer renderHTML:response];
			[self.webView loadHTMLString:HTML baseURL:nil];
			[searchBar resignFirstResponder];
		}];
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([text length]) {
		[self.db fetchCompletionListWithString:text callback:^(NSArray *list) {
			self.prefixArray = list;
			[self.tableView reloadData];
		}];
	}
}

@end
