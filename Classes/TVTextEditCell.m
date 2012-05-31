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
        //textEditField_.backgroundColor = [UIColor blueColor];
        [self.textLabel layoutIfNeeded];
        self.textLabel.font = [UIFont systemFontOfSize:12];
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
    //[super layoutSubviews];
    const float margin = 20.0;
    const float offset = 1.0;
    CGRect labelFrame = self.textLabel.frame;
    CGRect labelBounds = self.textLabel.bounds;
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

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( [delegate_ respondsToSelector:@selector(textEditCellShouldBeginEditing:)] ) {
        return [delegate_ textEditCellShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( [delegate_ respondsToSelector:@selector(textEditCellDidBeginEditing:)] ) {
        [delegate_ textEditCellDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if( [delegate_ respondsToSelector:@selector(textEditCellShouldEndEditing:)] ) {
        return [delegate_ textEditCellShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( [delegate_ respondsToSelector:@selector(textEditCellDidEndEditing:)] ) {
        [delegate_ textEditCellDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( [delegate_ respondsToSelector:@selector(textEditCell:shouldChangeCharactersInRange:replacementString:)] ) {
        return [delegate_ textEditCell:self shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if( [delegate_ respondsToSelector:@selector(textEditCellShouldClear:)] ) {
        return [delegate_ textEditCellShouldClear:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( [delegate_ respondsToSelector:@selector(textEditCellShouldReturn:)] ) {
        return [delegate_ textEditCellShouldReturn:self];
    }
    return YES;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textEditField_ release];
    [super dealloc];
}


@end
