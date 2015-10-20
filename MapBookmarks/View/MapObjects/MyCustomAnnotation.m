//
//  MyCustomAnnotation.m
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/18/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "MyCustomAnnotation.h"

@implementation MyCustomAnnotation

@synthesize coordinate, title;

// Designated initializer
- (id)initWithLocation:(CLLocationCoordinate2D)coord andTitle:(NSString *)annTitle {
    self = [super init];
    if (self) {
        coordinate = coord;
        title = annTitle;
    }
    return self;
}

@end
