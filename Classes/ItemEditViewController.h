//
//  ItemEditViewController.h
//  PWStore
//
//  Created by Andy Sawyer on 01/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWItem.h"

@interface ItemEditViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate> {
    PWItem *item_;
    IBOutlet UITextField *titleField;
    IBOutlet UITextField *loginField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *urlField;
    IBOutlet UITextField *emailField;
    IBOutlet UITextView *notesField;
}
@property (nonatomic,retain) PWItem *item;
@property (nonatomic,retain) IBOutlet UITextField *titleField;
@property (nonatomic,retain) IBOutlet UITextField *loginField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,retain) IBOutlet UITextField *urlField;
@property (nonatomic,retain) IBOutlet UITextField *emailField;
@property (nonatomic,retain) IBOutlet UITextView *notesField;

@end
