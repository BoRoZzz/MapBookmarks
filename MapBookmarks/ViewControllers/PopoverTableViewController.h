//
//  PopoverTableViewController.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/19/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Bookmark.h"

@class PopoverTableViewController;
@protocol PopoverTableViewControllerDelegate <NSObject>

@optional
- (void)turnRouteWithBookmark:(Bookmark *)bookmark;

@end

@interface PopoverTableViewController : CoreDataTableViewController

// Delegate id.
@property (nonatomic, weak) id <PopoverTableViewControllerDelegate> delegate;

// Passed data.
@property (strong, nonatomic) NSManagedObjectContext *bookmarksContext;

@end
