//
//  BookmarksTableViewController.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/15/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface BookmarksTableViewController : CoreDataTableViewController

// Passed data.
@property (strong, nonatomic) NSManagedObjectContext *bookmarksContext;

@end
