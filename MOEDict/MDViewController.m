#import "MDViewController.h"

@interface MDViewController ()
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
	self.searchBar.placeholder = NSLocalizedString(@"Your keyword", @"");
	self.searchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDisplayController.searchResultsDelegate = self;
	self.searchDisplayController.searchResultsDataSource = self;
	[self.view addSubview:self.searchBar];
	self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0)] autorelease];
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	//	self.webView.delegate = (id)self;
	[self.view addSubview:self.webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -

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
	NSDictionary *d = [self.prefixArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [d objectForKey:@"title"];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *d = [self.prefixArray objectAtIndex:indexPath.row];
	NSInteger entryID = [[d objectForKey:@"id"] integerValue];
	self.searchBar.text = [d objectForKey:@"title"];
	[self.db fetchDefinitionsWithID:entryID callback:^(NSDictionary *response) {
		NSString *HTML = [_HTMLRenderer renderHTML:response];
		[self.webView loadHTMLString:HTML baseURL:nil];
		[self.searchDisplayController setActive:NO animated:YES];
	}];
}

#pragma mark -

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

@synthesize searchDisplayController = searchDisplayController;

@end
