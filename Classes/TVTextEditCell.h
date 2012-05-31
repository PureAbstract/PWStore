//
//  TVTextEditCell.h
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TVTextEditCell : UITableViewCell<UITextFieldDelegate> {
    UITextField *textEditField_;
}
@property (nonatomic,readonly) UITextField *textEditField;
@end
