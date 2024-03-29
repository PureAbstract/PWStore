//
//  MasterPasswordViewController.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "MasterPasswordViewController.h"


@implementation MasterPasswordViewController
#pragma mark -
#pragma mark Properties
@synthesize passwordField = passwordField_;
@synthesize delegate = delegate_;
@synthesize mode = mode_;

-(NSString *)passwordText
{
    NSAssert( passwordField_, @"Null field" );
    NSAssert( passwordField_.text, @"Null text" );
    return passwordField_.text;
}

#pragma mark -
#pragma mark View Lifecycle
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    NSAssert( delegate_, @"Did you forget the delegate?" );
    [super viewDidLoad];
    [passwordField_ becomeFirstResponder];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.passwordField = nil;
}


#pragma mark -
#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [passwordField_ release];
    [super dealloc];
}


#pragma mark -
#pragma mark UITextFieldDelegate
// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Ideally, I'd like to disable the 'Done' button when the
    // password is empty...
    NSAssert( textField == passwordField_, @"Unexpected sender" );
    if( delegate_ ) {
        if( [delegate_ masterPasswordViewShouldClose:self] ) {
            [textField resignFirstResponder];
            return YES;
        }
    }
    return NO;
}

@end
