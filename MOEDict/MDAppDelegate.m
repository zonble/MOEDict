#import "MDAppDelegate.h"

@implementation MDAppDelegate

- (void)dealloc
{
	[_window release];
	[_rootViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version_preference"];

	if ([[UIDevice currentDevice].systemVersion doubleValue] < 7.0) {
		UIImage *whiteImage = nil;
		UIGraphicsBeginImageContext(CGSizeMake(320.0, 44.0));
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, 320.0, 44.0)] fill];
		whiteImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		[[UISearchBar appearance] setBackgroundImage:whiteImage];
	}

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.window.backgroundColor = [UIColor whiteColor];
	self.rootViewController = [[[IsIPad() ? [MDIPadViewController class] : [MDViewController class] alloc] init] autorelease];
	self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
