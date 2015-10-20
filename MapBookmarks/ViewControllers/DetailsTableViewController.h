//
//  DetailsTableViewController.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/19/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"

@interface DetailsTableViewController : UITableViewController

// Passed data.
@property (strong, nonatomic) Bookmark *bookmark;
@property (strong, nonatomic) NSManagedObjectContext *detailsContext;
@property (nonatomic)         BOOL segueFromMap;

@end
