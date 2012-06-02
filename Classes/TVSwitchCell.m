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


#pragma mark -
#pragma mark View Lifecycle
-(void)viewDidUnload
{
    [super viewDidUnload];
    self.switchControl = nil;
}
#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
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
}

@end
