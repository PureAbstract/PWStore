//
//  UIViewController+TabBarItem.h
//  PWStore
//
//  Created by Andy Sawyer on 30/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <Foundation/Foundation.h>


@interface UIViewController (TabBarItem)
-(void)setTabBarItemWithTitle:(NSString *)title
                    imageName:(NSString *)imageName
                          tag:(NSInteger)tag;

@end
