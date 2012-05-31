//
//  TVTextEditCell.m
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "TVTextEditCell.h"


@implementation TVTextEditCell
@synthesize delegate = delegate_;

-(UITextField *)textEditField {
    return textEditField_;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        textEditField_ = [[UITextField alloc] init];
        textEditField_.autoresizingMask = 0; // UIViewAutoresizingFlexibleWidth;
        textEditField_.delegate = self;
        textEditField_.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:textEditField_];
        self.contentView.autoresizesSubviews = YES;
        // Initialization code.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onTextFieldChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textEditField_];
    }
    return self;
}


-(void)layoutSubviews
{
    const float margin = 20.0;
    const float offset = 1.0;
    CGRect frame = self.contentView.frame;
    CGRect editFrame = CGRectInset( frame, margin, offset );
    editFrame.size.height = 25;
    textEditField_.frame = editFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state.
}

-(void)onTextFieldChanged:(NSNotification *)notification
{
    if( delegate_ ) {
        [delegate_ textEditCellChanged:self];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textEditField_ release];
    [super dealloc];
}


@end
