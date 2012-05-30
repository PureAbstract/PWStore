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

enum {
    kSaltLength = 16,
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

-(NSData *)encryptionKey
{
    NSAssert( password_, @"NULL Password" );
    NSAssert( password_.length > 0, @"Empty password" );
    return [password_ asDataUTF8];
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

-(NSMutableArray *)loadDataFromFile:(NSString *)filename
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
    if( [obj isKindOfClass:[NSMutableArray class]] ) {
        return (NSMutableArray *) obj;
    }
    if( [obj isKindOfClass:[NSArray class]] ) {
        return [NSMutableArray arrayWithArray:(NSArray *)obj];
    }
    NSLog(@"Unexpected object type %@",obj);
    return nil;
}

-(NSMutableArray *)loadData
{
    NSString *filename = [self defaultFile];
    return[self loadDataFromFile:filename];
}

-(NSMutableArray *)getData
{
    NSMutableArray *data = [self loadData];
    if( data ) {
        for( NSObject *obj in data ) {
            NSAssert( [obj isKindOfClass:[PWItem class]], @"Not a PWItem?" );
        }
        return data;
    }
    // Hack: Data for testing
    PWItem *pw = [PWItem new];
    pw.title = @"Title";
    pw.login = @"Login";
    pw.password = @"Password";
    pw.url = @"URL";
    pw.email = @"git@pureabstract.org";
    pw.notes = @"Notes and \n more notes";
    data = [NSMutableArray arrayWithObject:pw];
    [pw release];
    return data;
}

#pragma mark -
#pragma mark MasterPasswordViewControllerDelegate
-(BOOL)checkMasterPassword:(NSString *)check
{
    static NSString * const kKeyHash = @"pwhash";
    static NSString * const kKeySalt = @"pwsalt";
    // NOTE - this is TOTALLY BOGUS
    // We're saving an SHA256 hash of the master pw in the user defaults.
    // That isn't a good idea - but will sort of do for now.
    NSData *savedhash = [[NSUserDefaults standardUserDefaults] dataForKey:kKeyHash];
    NSData *savedsalt = [[NSUserDefaults standardUserDefaults] dataForKey:kKeySalt];
    NSData *pwdata = [check asDataUTF8];
    if( savedhash && savedsalt ) {
        NSMutableData *buffer= [NSMutableData dataWithCapacity:pwdata.length+savedsalt.length];
        [buffer appendData:pwdata];
        [buffer appendData:savedsalt];
        NSData *pwhash = [buffer sha256];
        return [pwhash isEqualToData:savedhash];
    } else {
        savedsalt = [NSData randomBytes:kSaltLength];
        NSMutableData *buffer = [NSMutableData dataWithCapacity:pwdata.length+savedsalt.length];
        [buffer appendData:pwdata];
        [buffer appendData:savedsalt];
        NSData *pwhash = [buffer sha256];
        [[NSUserDefaults standardUserDefaults] setObject:savedsalt forKey:kKeySalt];
        [[NSUserDefaults standardUserDefaults] setObject:pwhash forKey:kKeyHash];
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
    self.pwitems = [self getData];
    [self saveData];
    return YES;
}


#pragma mark -
#pragma mark Application lifecycle

-(void)setController:(UIViewController *)controller
 tabBarItemWithTitle:(NSString *)title
               image:(NSString *)imageName
                 tag:(NSInteger)tag
{
    UIImage *image = ( imageName ) ? [UIImage imageNamed:imageName] : nil;
    UITabBarItem *button = [[UITabBarItem alloc] initWithTitle:title
                                                         image:image
                                                           tag:tag];
    controller.tabBarItem = button;
    [button release];
}

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
        [self setController:controller
              tabBarItemWithTitle:NSLocalizedString(@"Data",nil)
                      image:@"icon_safe.png"
                        tag:0];
        [tabBarControllers addObject:controller];
    }
    {
        SyncViewController *controller = [[SyncViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.title = NSLocalizedString(@"Sync",nil);
        [self setController:controller
              tabBarItemWithTitle:NSLocalizedString(@"Sync",nil)
                      image:@"icon_refresh.png"
                        tag:0];
        [tabBarControllers addObject:controller];
        [controller release];
    }
    {
        SettingsViewController *controller = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.title = NSLocalizedString(@"Settings",nil);
        [self setController:controller
              tabBarItemWithTitle:NSLocalizedString(@"Settings",nil)
                      image:@"icon_settings.png"
                        tag:0];
        [tabBarControllers addObject:controller];
        [controller release];
    }
    {
        // This is a dummy view... we never actually display it.
        // The UITabBarControllerDelegate:shouldSelectViewController detects it,
        // and the puts up the lock screen.
        UIViewController *c = [UIViewController new];
        [self setController:c
              tabBarItemWithTitle:NSLocalizedString(@"Lock",nil)
                      image:@"icon_lock.png"
                        tag:kLockController];
        [tabBarControllers addObject:c];
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

