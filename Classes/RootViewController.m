//
//  RootViewController.m
//  PWStore
//
//  Created by Andy Sawyer on 29/05/2012.
//  Copyright 2012 Andy Sawyer
//

#import "RootViewController.h"
#import "ItemDetailViewController.h"
#import "ItemEditViewController.h"

@implementation RootViewController
#pragma mark -
#pragma mark Properties
@synthesize data = data_;

-(UISearchBar *)searchBar
{
    if( !searchBar_ ) {
        searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake( 0, 0,
                                                                    self.tableView.bounds.size.width,
                                                                    40 )];
        searchBar_.delegate = self;
        searchBar_.showsCancelButton = YES;
    }
    return searchBar_;
}

-(void)clearFilter
{
    if( filtered_ ) {
        [filtered_ release];
        filtered_ = nil;
        [self.tableView reloadData];
    }
}

-(void)applyFilter:(NSString *)text
{
    if( text && text.length ) {
        [filtered_ release];
        filtered_ = [NSMutableArray new];
        for( PWItem *item in data_ ) {
            NSString *title = item.title;
            NSRange range = [title rangeOfString:text
                                         options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            if( range.location != NSNotFound ) {
                [filtered_ addObject:item];
            }
        }
        [self.tableView reloadData];
    } else {
        [self clearFilter];
    }
}

-(void)showSearchBar:(BOOL)show
{
    if( show ) {
        self.tableView.tableHeaderView = self.searchBar;
        [searchBar_ becomeFirstResponder];
    } else {
        self.searchBar.text = @"";
        self.tableView.tableHeaderView = nil;
        [self clearFilter];
    }
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(onAddButton:)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                           target:self
                                                           action:@selector(onSearchButton:)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    self.title = NSLocalizedString(@"Data",nil);
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( filtered_ ) {
        return filtered_.count;
    }
    if( data_ ) {
        return data_.count;
    }
    return 0;
}

-(PWItem *)getItemForIndex:(NSIndexPath *)indexPath
{
    if( filtered_ ) {
        return [filtered_ objectAtIndex:indexPath.row];
    }
    if( data_ ) {
        return [data_ objectAtIndex:indexPath.row];
    }
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    PWItem *item = [self getItemForIndex:indexPath];
    cell.textLabel.text = item.title;

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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PWItem *item = [self.data objectAtIndex:indexPath.row];
    ItemDetailViewController *controller = [[ItemDetailViewController alloc] initWithItem:item];
    /*
      <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
      // ...
      // Pass the selected object to the new view controller.
      [self.navigationController pushViewController:detailViewController animated:YES];
      [detailViewController release];
    */
    [self.navigationController pushViewController:controller
                                         animated:YES];
    [controller release];
}

#pragma mark -
#pragma mark Button Events
-(void)onSearchButton:(NSObject *)sender
{
    [self showSearchBar:self.tableView.tableHeaderView==nil];
}

-(void)editViewSaved:(ItemEditViewController *)controller
{
    if( controller && controller.item ) {
        // Save the new item..
        [self.data addObject:controller.item];
        [self.tableView reloadData];
    }
}

-(void)onAddButton:(NSObject *)sender
{
    PWItem *newItem = [PWItem new];
    ItemEditViewController *controller = [[ItemEditViewController alloc] initWithItem:newItem
                                                                               target:self
                                                                               action:@selector(editViewSaved:)];
    [newItem release];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}
#pragma mark -
#pragma mark UISearchBarDelegate


// // return NO to not become first responder
// - (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
// // called when text starts editing
// - (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
// // return NO to not resign first responder
// - (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
// // called when text ends editing
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
// // called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self applyFilter:searchText];
}
// // called before text changes
// - (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

// // called when keyboard search button pressed
// - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
// // called when bookmark button pressed
// - (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;
// // called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self showSearchBar:NO];
}

//  // called when search results button pressed
// - (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar;

// - (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope;

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [filtered_ release];
    [data_ release];
    [searchBar_ release];
    [super dealloc];
}


@end

