//
//  RootViewController.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <UIKit/UIKit.h>
#import "PWData.h"
@interface RootViewController : UITableViewController {
    PWData *data_;
}
@property (nonatomic,retain) PWData *data;
@end
