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
    IBOutlet UITextField *titleField_;
    IBOutlet UITextField *loginField_;
    IBOutlet UITextField *passwordField_;
    IBOutlet UITextField *urlField_;
    IBOutlet UITextField *emailField_;
    IBOutlet UITextView *notesField_;
    IBOutlet UINavigationBar *navBar_;

    id<NSObject> target_;
    SEL action_;
}
@property (nonatomic,retain) PWItem *item;
@property (nonatomic,retain) IBOutlet UITextField *titleField;
@property (nonatomic,retain) IBOutlet UITextField *loginField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,retain) IBOutlet UITextField *urlField;
@property (nonatomic,retain) IBOutlet UITextField *emailField;
@property (nonatomic,retain) IBOutlet UITextView *notesField;
@property (nonatomic,retain) IBOutlet UINavigationBar *navBar;

-(id)initWithItem:(PWItem *)item target:(id<NSObject>)target action:(SEL)action;
+(id)controllerForItem:(PWItem *)item target:(id<NSObject>)target action:(SEL)action;


-(IBAction)onSave:(UIBarButtonItem *)sender;
-(IBAction)onCancel:(UIBarButtonItem *)sender;
@end
