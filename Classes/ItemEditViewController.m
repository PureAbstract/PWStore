//
//  ItemEditViewController.m
//  PWStore
//
//  Created by Andy Sawyer on 01/06/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "ItemEditViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ItemEditViewController
#pragma mark -
#pragma mark Properties
@synthesize item = item_;
@synthesize titleField;
@synthesize loginField;
@synthesize passwordField;
@synthesize urlField;
@synthesize emailField;
@synthesize notesField;
#pragma mark -

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
    if( item_ ) {
        titleField.text = item_.title;
        loginField.text = item_.login;
        passwordField.text = item_.password;
        urlField.text = item_.url;
        emailField.text = item_.email;
        notesField.text = item_.notes;

    }
    // Magic...
    notesField.layer.borderWidth = 1;
    notesField.layer.borderColor = [[UIColor grayColor] CGColor];
    notesField.layer.cornerRadius = 5;

    [titleField becomeFirstResponder];
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
    self.titleField = nil;
    self.loginField = nil;
    self.passwordField = nil;
    self.urlField = nil;
    self.emailField = nil;
    self.notesField = nil;
}


- (void)dealloc {
    [self.titleField release];
    [self.loginField release];
    [self.passwordField release];
    [self.urlField release];
    [self.emailField release];
    [self.notesField release];
    [item_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSInteger tag = textField.tag;
    if( tag ) {
        NSInteger tagNext = (tag+1);
        UIView *next = [self.view viewWithTag:tagNext];
        if( next ) {
            [next becomeFirstResponder];
        }
    }
    return YES;
}


@end
