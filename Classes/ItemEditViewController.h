//
//  ItemEditViewController.h
//  PWStore
//
//  Created by Andy Sawyer on 01/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWItem.h"

@interface ItemEditViewController : UIViewController {
    PWItem *item_;
}
@property (nonatomic,retain) PWItem *item;
@end
