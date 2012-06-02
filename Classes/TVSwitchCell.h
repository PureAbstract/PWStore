//
//  TVSwitchCell.h
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TVSwitchCell : UITableViewCell {
    UISwitch *switchControl_;
}
@property (nonatomic,retain) IBOutlet UISwitch *switchControl;
@end
