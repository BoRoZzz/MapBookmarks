//
//  MapViewController.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/15/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController
// Passed data.
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
