//
//  ItemDetailViewController.h
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWItem.h"

@interface ItemDetailViewController : UITableViewController {
    PWItem *item_;
}
@property (nonatomic,retain) PWItem *item;
-(id)initWithItem:(PWItem *)item;
@end
