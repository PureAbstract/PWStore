//
//  TVTextEditCell.h
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TVTextEditCell;

@protocol TVTextEditCellDelegate
-(void)textEditCellChanged:(TVTextEditCell *)textEditCell;
@end

@interface TVTextEditCell : UITableViewCell<UITextFieldDelegate> {
    UITextField *textEditField_;
    id<TVTextEditCellDelegate> delegate_;
}
@property (nonatomic,readonly) UITextField *textEditField;
@property (nonatomic,assign) id<TVTextEditCellDelegate> delegate;
@end
