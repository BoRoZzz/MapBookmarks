//
//  BookmarksTableViewController.m
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/15/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "DetailsTableViewController.h"
#import "Bookmark.h"

@interface BookmarksTableViewController ()

@end

@implementation BookmarksTableViewController

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarkCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.textAlignment       = NSTextAlignmentLeft;
    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.text                = bookmark.name;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.bookmarksContext deleteObject:bookmark];
        // Saving Context
        NSError *errorForSave = nil;
        if (![self.bookmarksContext save:&errorForSave]) {
            NSLog(@"Unable to save Bookmarks.");
            NSLog(@"%@, %@", errorForSave, errorForSave.localizedDescription);
        } else {
            NSLog(@"TEST MSG: bookmark saved scfly");
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - IBActions

- (IBAction)enterEditMode:(UIBarButtonItem *)sender {
    if (self.tableView.editing == NO) {
        NSLog(@"TEST MSG: Edit mode is on");
        self.tableView.editing = YES;
    } else {
        NSLog(@"TEST MSG: Edit mode is off");
        self.tableView.editing = NO;
    }
}

- (IBAction)backSegueOnDelete:(UIStoryboardSegue *)sender {
    NSLog(@"TEST MSG: Bookmark deleted. Unwind segue.");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailsTableViewController *vc = (DetailsTableViewController *)segue.destinationViewController;
    NSIndexPath *path = [self.tableView indexPathForCell:sender];
    Bookmark *bookmarkToPass = [self.fetchedResultsController objectAtIndexPath:path];
    vc.bookmark = bookmarkToPass;
    vc.detailsContext = self.bookmarksContext;
}

#pragma mark - APLC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
