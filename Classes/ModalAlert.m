//
//  ModalAlert.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "ModalAlert.h"

// TODO: Need to close this gracefully if the application terminates
@interface ModalAlertDelegate : NSObject<UIAlertViewDelegate>
{
    CFRunLoopRef runLoop_;
    NSUInteger result_;
}
@property (readonly) NSUInteger result;
@end


@implementation ModalAlertDelegate
@synthesize result = result_;
-(id)initWithRunLoop:(CFRunLoopRef)runLoop
{
    self = [super init];
    if( self ) {
        runLoop_ = runLoop;
    }
    return self;
}

-(id)init
{
    return [self initWithRunLoop:CFRunLoopGetCurrent()];
}

-(void)alertView:(UIAlertView *)view clickedButtonAtIndex:(NSInteger)index
{
    result_ = index;
    CFRunLoopStop( runLoop_ );
}
@end


@implementation ModalAlert
+(BOOL) showWithTitle:(NSString *)title okButton:(NSString *)ok cancelButton:(NSString *)cancel
{
    ModalAlertDelegate *delegate = [ModalAlertDelegate new];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:delegate
                                          cancelButtonTitle:cancel
                                          otherButtonTitles:ok,nil];
    [alert show];
    CFRunLoopRun();
    BOOL result = ( delegate.result != alert.cancelButtonIndex );
    [alert release];
    [delegate release];
    return result;
}

+(BOOL)showWithTitle:(NSString *)title
{
    return [self showWithTitle:title
                      okButton:NSLocalizedString(@"Ok",nil)
                  cancelButton:NSLocalizedString(@"Cancel",nil)];
}
@end
