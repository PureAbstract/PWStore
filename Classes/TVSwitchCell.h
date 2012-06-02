//
//  TVSwitchCell.h
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventTargets.h"

@interface TVSwitchCell : UITableViewCell {
    UISwitch *switchControl_;
    EventTargets *eventTargets_;
}
@property (nonatomic,retain) IBOutlet UISwitch *switchControl;
// For convenience - forwards to switchControl
@property (nonatomic,getter=isOn) BOOL on;

// When the switchControl changes, the action will be called with the TVSwitchCell as an argument:
// [target action:self]
-(void)addTarget:(id<NSObject>)target action:(SEL)action;
-(void)removeTarget:(id<NSObject>)target action:(SEL)action;
@end
