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
@synthesize titleField = titleField_;
@synthesize loginField = loginField_;
@synthesize passwordField = passwordField_;
@synthesize urlField = urlField_;
@synthesize emailField = emailField_;
@synthesize notesField = notesField_;
@synthesize navBar = navBar_;


#pragma mark -
#pragma mark Item/Control data xfer
// Put all this in one place for ease of maintainance...
-(void)transferData:(BOOL)saveToItem {
    if( item_ ) {
        if( saveToItem ) {
            item_.title = titleField_.text;
            item_.login = loginField_.text;
            item_.password = passwordField_.text;
            item_.url = urlField_.text;
            item_.email = emailField_.text;
            item_.notes = notesField_.text;
        } else {
            titleField_.text = item_.title;
            loginField_.text = item_.login;
            passwordField_.text = item_.password;
            urlField_.text = item_.url;
            emailField_.text = item_.email;
            notesField_.text = item_.notes;
        }
    }
}
#pragma mark -
#pragma mark View lifecycle

-(id)initWithItem:(PWItem *)item target:(id<NSObject>)target action:(SEL)action
{
    self = [super init];
    if( self ) {
        self.item = item;
        target_ = target;
        action_ = action;
    }
    return self;
}

+(id)controllerForItem:(PWItem *)item target:(id<NSObject>)target action:(SEL)action
{
    ItemEditViewController *controller = [[ItemEditViewController alloc] initWithItem:item target:target action:action];
    [controller autorelease];
    return controller;
}

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
    // Magic...
    notesField_.layer.borderWidth = 1;
    notesField_.layer.borderColor = [[UIColor grayColor] CGColor];
    notesField_.layer.cornerRadius = 5;

    [self transferData:NO];
    [titleField_ becomeFirstResponder];
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
    self.navBar = nil;
}


- (void)dealloc {
    [titleField_ release];
    [loginField_ release];
    [passwordField_ release];
    [urlField_ release];
    [emailField_ release];
    [notesField_ release];
    [navBar_ release];
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

#pragma mark -
#pragma mark UITextViewDelegate
// TODO: Scroll up here...
//- (void)textViewDidBeginEditing:(UITextView *)textView;


#pragma mark -
#pragma mark Target
-(void)endEditing:(BOOL)save
{
    if( target_ && action_ ) {
        [target_ performSelector:action_ withObject:(save ? self : nil)];
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Bar Button handlers
-(IBAction)onSave:(UIBarButtonItem *)sender
{
    [self transferData:YES];
    [self endEditing:YES];
}

-(IBAction)onCancel:(UIBarButtonItem *)sender
{
    self.item = nil;
    [self endEditing:NO];
}

@end
