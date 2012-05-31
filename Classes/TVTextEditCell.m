//
//  TVTextEditCell.m
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TVTextEditCell.h"


@implementation TVTextEditCell

-(UITextField *)textEditField {
    if( !textEditField_ ) {
        textEditField_ = [[UITextField alloc] init];
        textEditField_.delegate = self;
    }
    return textEditField_;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state.
}


- (void)dealloc {
    [textEditField_ release];
    [super dealloc];
}


@end
