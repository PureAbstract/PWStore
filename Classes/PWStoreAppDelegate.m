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
#import "SettingsViewController.h"
#import "SyncViewController.h"
#import "PWItem.h"
#import "NSData+AES.h"
#import "UIApplication+Utility.h"
#import "NSString+Utility.h"
#import "UIViewController+TabBarItem.h"

#pragma mark -
#pragma mark Constants
// Keys for NSUserDefaults
static NSString * const kMasterPWSalt = @"pwsalt";
static NSString * const kMasterPWHash = @"pwhash";

enum {
    // Number of bytes of random data to add to the actual data before
    // encryption.  The idea being that repeatedly encrypting the same
    // plaintext with the same key gives you a different ciphertext.
    kSaltLength = 16,
    // tag id of the 'Lockscreen' controller (which isn't really a
    // view controller)
    kLockController = 1041,
};

@implementation PWStoreAppDelegate
#pragma mark -
#pragma mark Properties
@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize tabBarController = tabBarController_;
@synthesize password = password_;
@synthesize pwitems = pwitems_;

-(BOOL)isLocked
{
    // Note: Is may be possible to ditch this locked_ flag, and check for password_ == nil?
    return locked_;
}

-(NSData *)encryptionKey
{
    NSAssert( password_, @"NULL Password" );
    NSAssert( password_.length > 0, @"Empty password" );
    return [password_ asDataUTF8];
}

#pragma mark -
#pragma mark Master Password
-(void)showMasterPasswordControllerAnimated:(BOOL)animated
{
    if( self.isLocked ) {
        return;
    }
    self.password = nil;
    MasterPasswordViewController *mpv = [[MasterPasswordViewController alloc] init];
    mpv.delegate = self;
    mpv.mode = kMasterPasswordEnterMode;
    locked_ = YES;
    [self.tabBarController presentModalViewController:mpv animated:animated];
    [mpv release];
}

-(void)showMasterPasswordController
{
    [self showMasterPasswordControllerAnimated:NO];
}

#pragma mark -
#pragma mark Test data

-(NSString *)defaultFile
{
    return [UIApplication documentPath:@"default.dat"];
}

-(void)saveDataInFile:(NSString *)filename
{
    NSData *key = [self encryptionKey];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pwitems_];
    NSData *enc = [data encryptWithKey:key
                            saltLength:kSaltLength];
    NSAssert( enc, @"Encryption problem" );
    // VERIFY
    NSData *dec = [enc decryptWithKey:key
                           saltLength:kSaltLength];
    NSAssert( dec, @"Decryption problem" );
    NSAssert( [dec isEqualToData:data], @"Encryption mismatch" );
    // END VERIFY
    NSError *error = nil;
    if( ![enc writeToFile:filename
                  options:(NSDataWritingAtomic|NSDataWritingFileProtectionComplete)
                    error:&error] ) {
        NSLog(@"Error saving file %@",error);
    }
    if( error ) {
        NSAssert( error == nil, @"Error saving file" );
    }
    // VERIFY
    NSData *load = [NSData dataWithContentsOfFile:filename];
    NSAssert( load, @"Load error");
    NSAssert( [load isEqualToData:enc], @"Load mismatch" );
    NSData *ldec = [enc decryptWithKey:key
                           saltLength:kSaltLength];
    NSAssert( [ldec isEqualToData:data], @"Decrypt mismatch" );
    // END VERIFY
}

-(void)saveData
{
    NSString *filename = [self defaultFile];
    return [self saveDataInFile:filename];
}

-(PWData *)loadDataFromFile:(NSString *)filename
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filename] ) {
        NSLog(@"File not found %@",filename);
        return nil;
    }
    NSData *load = [NSData dataWithContentsOfFile:filename];
    if( !load || ( load.length == 0 ) ) {
        NSLog(@"Failed to load from file");
        return nil;
    }
    NSData *dec = [load decryptWithKey:[self encryptionKey]
                            saltLength:kSaltLength];
    if( !dec ) {
        NSLog(@"Decryption error");
        return nil;
    }
    NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:dec];
    if( !obj ) {
        NSLog(@"Unarchive error");
        return nil;
    }
    if( [obj isKindOfClass:[PWData class]] ) {
        return (PWData *) obj;
    }
    NSLog(@"Unexpected object type %@",obj);
    return nil;
}

-(PWData *)loadData
{
    NSString *filename = [self defaultFile];
    return[self loadDataFromFile:filename];
}

-(PWData *)getData
{
    PWData *data = [self loadData];
    if( data ) {
        // Debug
        for( NSObject *obj in data ) {
            NSAssert( [obj isKindOfClass:[PWItem class]], @"Not a PWItem?" );
        }
        // End Debug
        return data;
    }
    data = [[[PWData alloc] init] autorelease];
#ifdef TEST_DATA
    // Just some data for testing
    PWItem *pw = [PWItem new];
    pw.title = @"Title";
    pw.login = @"Login";
    pw.password = @"Password";
    pw.url = @"URL";
    pw.email = @"spamtrap@pureabstract.org";
    pw.notes = @"Notes and \n more notes";
    [data addObject:pw];
    [pw release];

    pw = [PWItem new];
    pw.title = @"Other Title";
    pw.login = @"other login";
    pw.password = @"Another password";
    pw.url = @"The URL";
    pw.email = @"devnull@example.com";
    pw.notes = @"Notes on this item";
    [data addObject:pw];
    [pw release];
#endif
    return data;
}

#pragma mark -
#pragma mark MasterPasswordViewControllerDelegate
-(BOOL)checkMasterPassword:(NSString *)check
{
    // NOTE - this is TOTALLY BOGUS
    // We're saving an SHA256 hash of the master pw in the user defaults.
    // That isn't a good idea - but will sort of do for now.
    // At the very least, we should do multiple rounds of hashing.
    NSData *savedhash = [[NSUserDefaults standardUserDefaults] dataForKey:kMasterPWHash];
    NSData *savedsalt = [[NSUserDefaults standardUserDefaults] dataForKey:kMasterPWSalt];
    NSData *pwdata = [check asDataUTF8];
    if( savedhash && savedsalt ) {
        // We already have a saved master password.
        // So hash the newly entered one with the salt...
        NSMutableData *buffer= [NSMutableData dataWithCapacity:pwdata.length+savedsalt.length];
        [buffer appendData:pwdata];
        [buffer appendData:savedsalt];
        NSData *pwhash = [buffer sha256];
        // And compare it with the saved one
        return [pwhash isEqualToData:savedhash];
    } else {
        // No saved data, so generate some salt...
        savedsalt = [NSData randomBytes:kSaltLength];
        // hash it with the password
        NSMutableData *buffer = [NSMutableData dataWithCapacity:pwdata.length+savedsalt.length];
        [buffer appendData:pwdata];
        [buffer appendData:savedsalt];
        NSData *pwhash = [buffer sha256];
        // Save the results
        [[NSUserDefaults standardUserDefaults] setObject:savedsalt forKey:kMasterPWSalt];
        [[NSUserDefaults standardUserDefaults] setObject:pwhash forKey:kMasterPWHash];
    }
    return YES;
}


-(BOOL)masterPasswordViewShouldClose:(MasterPasswordViewController *)controller
{
    //    NSAssert( self.tabBarController.modalView == contoller, @"Not the modal controller" );
    if( controller.passwordText.length == 0 ) {
        return NO;
    }
    NSString *pw = controller.passwordText;
    if( ![self checkMasterPassword:pw] ) {
        return NO;
    }
    self.password = pw;
    [self.tabBarController dismissModalViewControllerAnimated:YES];
    locked_ = NO;
    self.pwitems = [self getData];
    [self saveData];            // FIXME
    if( navigationController_ ) {
        if( navigationController_.viewControllers ) {
            if( navigationController_.viewControllers.count > 0 ) {
                NSObject *view = [navigationController_.viewControllers objectAtIndex:0];
                if( [view isKindOfClass:[RootViewController class]] ) {
                    RootViewController *root = (RootViewController *)view;
                    root.data = self.pwitems;
                }
            }
        }
    }
    return YES;
}

// Called when we get a notification that data has been changed
-(void)dataUpdated:(NSNotification *)notification
{
    // Check we're unlocked.
    if( self.isLocked ) {
        NSAssert( NO, @"data update while locked" );
    } else {
        [self saveData];
    }
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.


    // Add views to tab bar
    NSMutableArray *tabBarControllers = [NSMutableArray arrayWithCapacity:4];
    //[tabBarControllers addObject:navigationController];

    // NOTE: iPhone 3 size is 30x30, Retina is 60x60
    // These are just here for examples...
    {
        UIViewController *controller = self.navigationController;
        controller.title = NSLocalizedString(@"Data",nil);
        [controller setTabBarItemWithTitle:NSLocalizedString(@"Data",nil)
                                 imageName:@"icon_safe.png"
                                       tag:0];
        [tabBarControllers addObject:controller];
    }
    {
        SyncViewController *controller = [[SyncViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.title = NSLocalizedString(@"Sync",nil);
        [controller setTabBarItemWithTitle:NSLocalizedString(@"Sync",nil)
                                     imageName:@"icon_refresh.png"
                                       tag:0];
        [tabBarControllers addObject:controller];
        [controller release];
    }
    {
        SettingsViewController *controller = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.title = NSLocalizedString(@"Settings",nil);
        [controller setTabBarItemWithTitle:NSLocalizedString(@"Settings",nil)
                                     imageName:@"icon_settings.png"
                                       tag:0];
        [tabBarControllers addObject:controller];
        [controller release];
    }
    {
        // This is a dummy view... we never actually display it.
        // The UITabBarControllerDelegate:shouldSelectViewController detects it,
        // and the puts up the lock screen.
        UIViewController *c = [UIViewController new];
        [c setTabBarItemWithTitle:NSLocalizedString(@"Lock",nil)
                        imageName:@"icon_lock.png"
                              tag:kLockController];
        [tabBarControllers addObject:c];
        [c release];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataUpdated:)
                                                 name:kPWDataUpdated
                                               object:nil];

    tabBarController_.viewControllers = tabBarControllers;

    // Add the navigation controller's view to the window and display.
    [self.window addSubview:tabBarController_.view];
    //[self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    [self showMasterPasswordController];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self showMasterPasswordController];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self showMasterPasswordController];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [self showMasterPasswordController];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self showMasterPasswordController];
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

