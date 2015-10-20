//
//  Bookmark+CoreDataProperties.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/20/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Bookmark.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bookmark (CoreDataProperties)

@property (nullable, nonatomic, retain) id location;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
