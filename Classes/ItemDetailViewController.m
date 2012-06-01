//
//  ItemDetailViewController.m
//  PWStore
//
//  Created by Andy Sawyer on 31/05/2012.
//  Copyright 2012 Andy Sawyer. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ItemEditViewController.h"

@implementation ItemDetailViewController
@synthesize item = item_;

#pragma mark -
#pragma mark Initialization

enum {
    kIndexTitle = 0,
    kIndexLogin,
    kIndexPassword,
    kIndexUrl,
    kIndexEmail,
    kIndexNotes,

    kIndexMax,
};

static NSString *cellLabels [] = {
    @"Title",
    @"Login",
    @"Password",
    @"URL",
    @"Email",
    @"Notes",
};

-(id)initWithItem:(PWItem *)item
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if( self ) {
        self.item = item;
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void)onEditSaved:(ItemEditViewController *)controller
{
    // Update the view
    if( controller && controller.item ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPWDataUpdated
                                                            object:controller.item];
        [self.tableView reloadData];
    }
}

-(void)onEdit:(UIBarButtonItem *)sender
{
    ItemEditViewController *controller = [[ItemEditViewController alloc] initWithItem:self.item
                                                                               target:self
                                                                               action:@selector(onEditSaved:)];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                            target:self
                                                                                            action:@selector(onEdit:)] autorelease];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kIndexMax;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    NSUInteger itemIndex = indexPath.section;
    cell.tag = itemIndex;
    NSString *text = nil;
    switch( itemIndex ) {
    case kIndexTitle: text = item_.title; break;
    case kIndexLogin: text = item_.login; break;
    case kIndexPassword: text = item_.password; break;
    case kIndexUrl: text = item_.url; break;
    case kIndexEmail: text = item_.email; break;
    case kIndexNotes: text = item_.notes; break;
    default:
        NSAssert( NO, @"Index out of range" );
        text = @"";
        break;
    }

    cell.textLabel.text = text;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return cellLabels[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Notes
    if( indexPath.section == 5 ) {
        return tableView.rowHeight * 5;
    }
    return tableView.rowHeight;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [item_ release];
    [super dealloc];
}


@end

