//
//  MasterPasswordViewController.h
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import <UIKit/UIKit.h>

@class MasterPasswordViewController;

@protocol MasterPasswordViewControllerDelegate
-(BOOL)masterPasswordViewShouldClose:(MasterPasswordViewController *)controller;
@end

@interface MasterPasswordViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *passwordField_;
    id<MasterPasswordViewControllerDelegate> delegate_;
}
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,assign) id<MasterPasswordViewControllerDelegate> delegate;
@property (nonatomic,readonly) NSString *passwordText;

@end
