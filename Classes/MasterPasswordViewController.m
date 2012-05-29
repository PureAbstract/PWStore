//
//  MasterPasswordViewController.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "MasterPasswordViewController.h"


@implementation MasterPasswordViewController
@synthesize passwordField = passwordField_;
@synthesize delegate = delegate_;

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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.passwordField = nil;
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
    NSAssert( textField == passwordField_, @"Unexpected sender" );
    if( textField.text.length > 0 ) {
        [textField resignFirstResponder];
        if( delegate_ ) {
            return [delegate_ masterPasswordViewShouldClose:self];
        }
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -

@end
