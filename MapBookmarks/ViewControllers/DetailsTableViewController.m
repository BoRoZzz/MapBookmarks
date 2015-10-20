//
//  DetailsTableViewController.m
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/19/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "DetailsTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationObject.h"
#import "NetworkFetcher.h"
#import "Defines.h"

@interface DetailsTableViewController () <NetworkFetcherDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// Outlets
@property (weak, nonatomic) IBOutlet UIButton     *loadNearbyPlaces;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

// Private props.
@property (nonatomic) BOOL pickerIsShowing;
@property (strong, nonatomic) NSArray *places;

@end

@implementation DetailsTableViewController

#pragma mark - VCLC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Views setup
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    if (self.bookmark) {
        if ([self.bookmark.name isEqualToString:@"Unnamed"]) {
            NSLog(@"TEST MSG: Bookmark unnamed");
            [self showDatePickerCell];
            self.picker.backgroundColor = [UIColor clearColor];
            [self.navigationItem setTitle:@"Unnamed bookmark"];
            [self loadPlaces];
        } else {
            NSLog(@"TEST MSG: Bookmark named");
            [self hideDatePickerCell];
            [self.navigationController setTitle:self.bookmark.name];
        }
    } else {
        NSLog(@"ERROR MSG: Bookmark is nil");
        [self hideDatePickerCell];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UIPickerViewDataSource and UIPickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.places count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.places count]) {
        //NSLog(@"TEST MSG: picker should return");
        LocationObject *object = [self.places objectAtIndex:row];
        return object.name;
    } else {
        return @"Location name";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    LocationObject *temp = [self.places objectAtIndex:row];
    self.bookmark.name = temp.name;
    self.navigationItem.title = temp.name;
    [self hideDatePickerCell];
    // Saving Context
    NSError *errorForSave = nil;
    if (![self.detailsContext save:&errorForSave]) {
        NSLog(@"Unable to save Bookmarks.");
        NSLog(@"%@, %@", errorForSave, errorForSave.localizedDescription);
    } else {
        NSLog(@"TEST MSG: bookmark saved scfly for name");
    }
}

#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.section == 0 && indexPath.row == 1){
        height = self.pickerIsShowing ? 216.0f : 0.0f;
    }
    return height;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    return YES;
}
*/

#pragma mark - Helper methods

// Picker methods

- (void)loadPlaces {
    CLLocation *temp = self.bookmark.location;
    NSString *urlString = [NSString stringWithFormat:
                           @"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%f,%f",
                           CLIENT_ID, CLIENT_SECRET, temp.coordinate.latitude, temp.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NetworkFetcher *fetcher = [[NetworkFetcher alloc] initWithURL:url];
    fetcher.delegate = self;
}

- (void)showDatePickerCell {
    self.pickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    
    [self.tableView endUpdates];
    
    self.picker.hidden = NO;
    self.picker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.picker.alpha = 1.0f;
        
    }];
}

- (void)hideDatePickerCell {
    
    self.pickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.picker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.picker.hidden = YES;
                     }];
}

#pragma mark - NetworkFetcherDelegate

- (void)resultsArray:(NSMutableArray *)array {
    NSLog(@"TEST MSG: Network delegate called");
    self.places = array;
    [self.tableView reloadData];
    [self.picker reloadAllComponents];
}

#pragma mark - IBActions

- (IBAction)removeBookmark:(UIBarButtonItem *)sender {
    if (self.bookmark) {
        NSString *delMSG = [NSString stringWithFormat:@"Are you sure you want to delete the %@ bookmark?", self.bookmark.name];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete bookmark?"
                                              message:delMSG preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel  = [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Ok"
                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.detailsContext deleteObject:self.bookmark];
            // Saving Context
            NSError *errorForSave = nil;
            if (![self.detailsContext save:&errorForSave]) {
                NSLog(@"Unable to save Bookmarks.");
                NSLog(@"%@, %@", errorForSave, errorForSave.localizedDescription);
            } else {
                NSLog(@"TEST MSG: bookmark saved scfly");
            }
            // One solution > there is no data to pass so...it can be
            //[self.navigationController popViewControllerAnimated:YES];
            
            // As requested by test assignment
            if (self.segueFromMap) {
                [self performSegueWithIdentifier:@"unwindSegueToMaps" sender:self];
            } else {
                [self performSegueWithIdentifier:@"unwindSegueToBookmarks" sender:self];
            }
        }];
        [alertController addAction:confirm];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSLog(@"ERROR MSG: self.bookmark = nil");
    }
}

- (IBAction)loadNearbyPlaces:(UIButton *)sender {
    if (self.pickerIsShowing == NO) {
        [self showDatePickerCell];
        [self loadPlaces];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"centerInMap"]) {
        return;
    } else if ([segue.identifier isEqualToString:@"showRoute"]) {
        
    }
}

#pragma mark - APLC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
