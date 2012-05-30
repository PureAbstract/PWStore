//
//  UIViewController+TabBarItem.m
//  PWStore
//
//  Created by Andy Sawyer on 30/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "UIViewController+TabBarItem.h"


@implementation UIViewController (TabBarItem)

-(void)setTabBarItemWithTitle:(NSString *)title
                    imageName:(NSString *)imageName
                          tag:(NSInteger)tag
{
    UIImage *image = ( imageName ) ? [UIImage imageNamed:imageName] : nil;
    UITabBarItem *button = [[UITabBarItem alloc] initWithTitle:title
                                                         image:image
                                                           tag:tag];
    self.tabBarItem = button;
    [button release];
}

@end
