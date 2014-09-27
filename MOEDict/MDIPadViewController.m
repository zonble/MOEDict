#import <QuartzCore/QuartzCore.h>
#import "MDIPadViewController.h"

@interface MDIPadMainView : UIView
@property (assign, nonatomic) UIView *leftView;
@property (assign, nonatomic) UIView *rightView;
@end

@implementation MDIPadMainView

- (void)layoutSubviews
{
	CATransition *t = [CATransition animation];
	CGSize size = self.bounds.size;
	CGFloat w = (size.width > size.height) ? 320 : 260;
	self.leftView.frame = CGRectMake(0.0, 20.0, w - 1, self.bounds.size.height - 20.0);
	self.rightView.frame = CGRectMake(w, 20.0, self.bounds.size.width - w, self.bounds.size.height - 20.0);

	if (!self.leftView.superview) {
		[self addSubview:self.leftView];
	}
	if (!self.rightView.superview) {
		[self addSubview:self.rightView];
	}
	[self.layer addAnimation:t forKey:@"transition"];
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
	self.view.backgroundColor = [UIColor whiteColor];

	self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width - 320.0, self.view.bounds.size.height)] autorelease];
	self.webView.delegate = self;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[[self.webView.subviews lastObject] setBackgroundColor:[UIColor whiteColor]];
	for (UIView *v in [[self.webView.subviews lastObject] subviews]) {
		[v setBackgroundColor:[UIColor whiteColor]];
		v.layer.shadowOffset = CGSizeZero;
		if ([v isKindOfClass:[UIImageView class]]) {
			[(UIImageView *)v setImage:nil];
		}
	}
	self.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height)] autorelease];;

	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
	self.searchBar.delegate = self;
	self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
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

- (void)searchWithKeyword:(NSString *)inKeyword
{
	[self.db fetchDefinitionsWithKeyword:inKeyword callback:^(NSDictionary *response) {
		NSString *HTML = [self.HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
		[self.searchBar resignFirstResponder];
	}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *d = [self.prefixArray objectAtIndex:indexPath.row];
	NSInteger entryID = [[d objectForKey:kMDIdentifierKey] integerValue];
	[self.db fetchDefinitionsWithID:entryID callback:^(NSDictionary *response) {
		NSString *HTML = [self.HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
		[self.searchBar resignFirstResponder];
	}];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.searchBar resignFirstResponder];
}

@end
