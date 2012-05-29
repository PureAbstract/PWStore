//
//  PWStoreAppDelegate.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "PWStoreAppDelegate.h"
#import "RootViewController.h"
#import "MasterPasswordViewController.h"
#import "PWItem.h"
#import "NSData+AES.h"
enum {

    kLockController = 1041,
};

@implementation PWStoreAppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize tabBarController = tabBarController_;
@synthesize password = password_;
@synthesize pwitems = pwitems_;


#pragma mark -
#pragma mark Master Password
-(void)showMasterPasswordControllerAnimated:(BOOL)animated
{
    self.password = nil;
    self.pwitems = [NSMutableArray arrayWithCapacity:0];
    MasterPasswordViewController *mpv = [[MasterPasswordViewController alloc] init];
    mpv.delegate = self;
    [self.tabBarController presentModalViewController:mpv animated:animated];
    [mpv release];
}

-(void)showMasterPasswordController
{
    [self showMasterPasswordControllerAnimated:NO];
}

#pragma mark -
#pragma mark Test data
-(NSString *)documentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

-(NSString *)defaultFile
{
    return [[self documentFolder] stringByAppendingPathComponent:@"default.dat"];
}

-(void)saveData
{
    NSData *key = [NSMutableData dataWithLength:32];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pwitems_];
    NSData *enc = [data encryptWithKey:key
                            saltLength:16];
    NSAssert( enc, @"Encryption problem" );
    // Verify...
    NSData *dec = [enc decryptWithKey:key
                           saltLength:16];
    NSAssert( dec, @"Decryption problem" );
    NSAssert( [dec isEqualToData:data], @"Encryption mismatch" );

    NSError *error = nil;
    [enc writeToFile:[self defaultFile]
             options:(NSDataWritingAtomic|NSDataWritingFileProtectionComplete)
               error:&error];
    if( error ) {
    }
    NSData *load = [NSData dataWithContentsOfFile:[self defaultFile]];
    NSAssert( load, @"Load error");
    NSAssert( [load isEqualToData:enc], @"Load mismatch" );
    NSData *ldec = [enc decryptWithKey:key
                           saltLength:16];
    NSAssert( [ldec isEqualToData:data], @"Decrypt mismatch" );
}

-(NSMutableArray *)getData
{
    // Hack: Data for testing
    PWItem *pw = [PWItem new];
    pw.title = @"Title";
    pw.login = @"Login";
    pw.password = @"Password";
    pw.url = @"URL";
    pw.email = @"git@pureabstract.org";
    pw.notes = @"Notes and \n more notes";
    NSMutableArray *arr = [NSMutableArray arrayWithObject:pw];
    [pw release];
    return arr;
}

#pragma mark -
#pragma mark MasterPasswordViewControllerDelegate
-(BOOL)masterPasswordViewShouldClose:(MasterPasswordViewController *)controller
{
    //    NSAssert( self.tabBarController.modalView == contoller, @"Not the modal controller" );
    if( controller.passwordText.length > 0 ) {
        self.password = controller.passwordText;
        [self.tabBarController dismissModalViewControllerAnimated:YES];
        self.pwitems = [self getData];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.


    // Add views to tab bar
    NSMutableArray *tabBarControllers = [NSMutableArray arrayWithCapacity:4];
    //[tabBarControllers addObject:navigationController];

    // These are just here for examples...
    {
        RootViewController *c = [[RootViewController alloc] initWithStyle:UITableViewStyleGrouped];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Data",nil)
                                                           image:nil
                                                             tag:0];
        c.tabBarItem = item;
        [tabBarControllers addObject:c];
        [item release];
        [c release];
    }
    {
        UITableViewController *c = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sync",nil)
                                                           image:[UIImage imageNamed:@"get.png"]
                                                             tag:0];
        c.tabBarItem = item;
        [tabBarControllers addObject:c];
        [item release];
        [c release];
    }
    {
        // This is a dummy view...
        UIViewController *c = [UIViewController new];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Lock",nil)
                                                           image:[UIImage imageNamed:@"lock32.png"]
                                                             tag:kLockController];
        c.tabBarItem = item;
        [tabBarControllers addObject:c];
        [item release];
        [c release];
    }

    tabBarController_.viewControllers = tabBarControllers;

    // Add the navigation controller's view to the window and display.
    [self.window addSubview:tabBarController_.view];
    //[self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    self.pwitems = [NSMutableArray arrayWithCapacity:0];
    [self showMasterPasswordController];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark UITabBarController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController
         shouldSelectViewController:(UIViewController *)viewController
{
    if( [UIViewController class] == [viewController class] ) {
        [self showMasterPasswordControllerAnimated:YES];
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController_ release];
    [navigationController_ release];
    [window_ release];
    [password_ release];
    [pwitems_ release];
    [super dealloc];
}


@end

