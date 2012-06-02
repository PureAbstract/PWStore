//
//  TVSwitchCell.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "TVSwitchCell.h"

@implementation TVSwitchCell
#pragma mark -
#pragma mark Properties
@synthesize switchControl = switchControl_;

-(BOOL)isOn
{
    return switchControl_.isOn;
}

-(void)setOn:(BOOL)on
{
    switchControl_.on = on;
}

-(EventTargets *)targets
{
    if( !targets_ ) {
        targets_ = [EventTargets new];
    }
    return targets_;
}

#pragma mark -
#pragma mark Initialisation
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        CGRect frame = CGRectMake(198.0, 12.0, 94.0, 27.0); // Straight out of UICatalog sample...
        switchControl_ = [[UISwitch alloc] initWithFrame:frame];
        switchControl_.backgroundColor = [UIColor clearColor];
        [switchControl_ addTarget:self
                           action:@selector(switchAction:)
                 forControlEvents:UIControlEventValueChanged];
        self.accessoryView = switchControl_;
    }
    return self;
}

-(void)addTarget:(id<NSObject>)target action:(SEL)action
{
    [self.targets addTarget:target action:action];
}

-(void)removeTarget:(id<NSObject>)target action:(SEL)action
{
    if( targets_ ) {
        [targets_ removeTarget:targets_ action:action];
    }
}


#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    [targets_ release];
    [switchControl_ removeTarget:self
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
    [switchControl_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark TableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state.
}

#pragma mark -
#pragma mark Switch cell events
-(void)switchAction:(id)sender
{
    // Switch was changed
    NSAssert( sender == switchControl_, @"Unexpected sender" );
    BOOL state = switchControl_.isOn;
    if( targets_ ) {
        [targets_ sendActionsWithObject:self];
    }
}

@end
