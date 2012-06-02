//
//  ModalAlert.m
//  PWStore
//
//  Created by Andy Sawyer on 02/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "ModalAlert.h"

@interface ModalAlertDelegate : NSObject<UIAlertViewDelegate>
{
    CFRunLoopRef runLoop_;
    NSUInteger result_;
}
@property (readonly) NSUInteger result;
@end

@implementation ModalAlertDelegate
@synthesize result = result_;

-(id)init
{
    self = [super init];
    if( self ) {
        runLoop_ = CFRunLoopGetCurrent();
    }
    return self;
}

-(void)alertView:(UIAlertView *)view clickedButtonAtIndex:(NSInteger)index
{
    result_ = index;
    CFRunLoopStop( runLoop_ );
}
@end


@implementation ModalAlert

+(BOOL)showWithTitle:(NSString *)title
{
    ModalAlertDelegate *delegate = [ModalAlertDelegate new];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:nil
                                                   delegate:delegate
                                          cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                          otherButtonTitles:NSLocalizedString(@"Ok",nil),nil];
    [alert show];
    CFRunLoopRun();
    BOOL result = ( delegate.result != alert.cancelButtonIndex );
    [alert release];
    [delegate release];
    return result;
}
@end
