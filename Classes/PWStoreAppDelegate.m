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

@implementation PWStoreAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;

#pragma mark -
#pragma mark Master Password
-(void)showMasterPasswordController
{
    MasterPasswordViewController *mpv = [[MasterPasswordViewController alloc] init];
    mpv.delegate = self;
    [self.tabBarController presentModalViewController:mpv animated:NO];
    [mpv release];
}

#pragma mark -
#pragma mark MasterPasswordViewControllerDelegate
-(BOOL)masterPasswordViewShouldClose:(MasterPasswordViewController *)controller
{
    //    NSAssert( self.tabBarController.modalView == contoller, @"Not the modal controller" );
    [self.tabBarController dismissModalViewControllerAnimated:YES];
    return YES;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.


    // Add views to tab bar
    NSMutableArray *tabBarControllers = [NSMutableArray arrayWithCapacity:4];
    //[tabBarControllers addObject:navigationController];
    {
        RootViewController *c = [[RootViewController alloc] initWithStyle:UITableViewStyleGrouped];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Home"
                                                           image:nil
                                                             tag:0];
        c.tabBarItem = item;
        [tabBarControllers addObject:c];
        [item release];
        [c release];
    }
    {
        UITableViewController *c = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Away"
                                                           image:nil
                                                             tag:0];
        c.tabBarItem = item;
        [tabBarControllers addObject:c];
        [item release];
        [c release];
    }

    tabBarController.viewControllers = tabBarControllers;

    // Add the navigation controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
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
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

