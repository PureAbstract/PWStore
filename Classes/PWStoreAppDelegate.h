//
//  PWStoreAppDelegate.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <UIKit/UIKit.h>
#import "MasterPasswordViewController.h"

@interface PWStoreAppDelegate : NSObject <UIApplicationDelegate,
                                          UITabBarControllerDelegate,
                                          MasterPasswordViewControllerDelegate> {
    UIWindow *window_;
    UINavigationController *navigationController_;
    UITabBarController *tabBarController_;
    NSString *password_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, copy) NSString *password;

@end

