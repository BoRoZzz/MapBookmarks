//
//  PopoverTableViewController.m
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/19/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "PopoverTableViewController.h"
#import "MapViewController.h"
#import "Bookmark.h"

@interface PopoverTableViewController ()

@end

@implementation PopoverTableViewController

#pragma mark - VCLC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
    
    // Add Sort Descriptors and predicates
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:
                                     self.bookmarksContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarkPopoverCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.textAlignment       = NSTextAlignmentLeft;
    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.text                = bookmark.name;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Unfortunately the Unwind segue doesn't work with popover
    
    Bookmark *bookmarkToPass = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate turnRouteWithBookmark:bookmarkToPass];
     
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismiss" object:self];
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
        // Delete the row from the data source
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    return NO;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - APLC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
