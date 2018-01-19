#import "MDViewController.h"

@interface MDViewController ()
@property (retain, nonatomic) UISearchDisplayController *searchDisplayController;
@end

@implementation MDViewController

- (void)dealloc
{
	[_db release];
	[_HTMLRenderer release];
	[_prefixArray release];
	[_webView release];
	[_searchBar release];
	[searchDisplayController release];
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"db" ofType:@"sqlite3"];
		_db = [[MDDatabase alloc] initWithPath:path];
		_HTMLRenderer = [[MDHTMLRenderer alloc] init];
	}
	return self;
}

- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)] autorelease];
	self.searchBar.delegate = self;
	self.searchBar.placeholder = NSLocalizedString(@"Your Keyword", @"");
	self.searchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDisplayController.searchResultsDelegate = self;
	self.searchDisplayController.searchResultsDataSource = self;
	self.searchDisplayController.searchResultsTitle = NSLocalizedString(@"Matches", @"");
	[self.view addSubview:self.searchBar];
	self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0)] autorelease];
	self.webView.delegate = self;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[[self.webView.subviews lastObject] setBackgroundColor:[UIColor whiteColor]];
	for (UIView *v in [[self.webView.subviews lastObject] subviews]) {
		[v setBackgroundColor:[UIColor whiteColor]];
		v.layer.shadowOffset = CGSizeZero;
		if ([v isKindOfClass:[UIImageView class]]) {
			[(UIImageView *) v setImage:nil];
		}
	}
	[self.view addSubview:self.webView];

	self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
	self.searchBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
	self.webView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);

	self.view.backgroundColor = [UIColor whiteColor];
	self.webView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews
{
	if (@available(iOS 11.0, *)) {
		UIEdgeInsets safeArea = self.view.safeAreaInsets;
		CGFloat top = safeArea.top;
		if (top < 20) {
			top = 20;
		}
		self.searchBar.frame = CGRectMake(0.0, top, self.view.bounds.size.width, 44.0);
		self.webView.frame = CGRectMake(0.0, top + 44, self.view.bounds.size.width, self.view.bounds.size.height - (top + 44));
	}
	else {
		self.searchBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
		self.webView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.db fetchDefinitionsWithKeyword:@"萌" callback:^(NSDictionary *response) {
		NSString *HTML = [self.HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
	}];
}

- (void)viewDidUnload
{
	self.searchBar = nil;
	self.webView = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)searchWithKeyword:(NSString *)inKeyword
{
	[self.db fetchDefinitionsWithKeyword:inKeyword callback:^(NSDictionary *response) {
		NSString *HTML = [self.HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
		[self.searchBar resignFirstResponder];
		[self.searchDisplayController setActive:NO animated:YES];
	}];
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.prefixArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	NSDictionary *d = self.prefixArray[indexPath.row];
	cell.textLabel.text = d[kMDTitleKey];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *d = self.prefixArray[indexPath.row];
	NSInteger entryID = [d[kMDIdentifierKey] integerValue];
	self.searchBar.text = d[kMDTitleKey];
	[self.db fetchDefinitionsWithID:entryID callback:^(NSDictionary *response) {
		NSString *HTML = [self.HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
		[self.searchDisplayController setActive:NO animated:YES];
	}];
}

#pragma mark -
#pragma mark UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([text length]) {
		[self searchWithKeyword:text];
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSString *text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([text length]) {
		[self.db fetchCompletionListWithString:text callback:^(NSArray *list) {
			self.prefixArray = list;
			[self.searchDisplayController.searchResultsTableView reloadData];
		}];
	}
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *URLString = [[request URL] absoluteString];
	if ([URLString hasPrefix:@"moe://"]) {
		NSString *s = [[URLString substringFromIndex:[@"moe://" length]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if ([s length]) {
			[self searchWithKeyword:s];
			return NO;
		}
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}


@synthesize searchDisplayController = searchDisplayController;

@end
