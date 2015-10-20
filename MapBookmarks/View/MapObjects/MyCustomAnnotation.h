//
//  MyCustomAnnotation.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyCustomAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString* title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString    *title;

// Designated initializer
- (id)initWithLocation:(CLLocationCoordinate2D)coord andTitle:(NSString *)annTitle;

@end
