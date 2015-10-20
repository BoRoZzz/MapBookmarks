//
//  NetworkFetcher.h
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/19/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

// Declaring protocol in order to inform ViewController about updated data
@class NetworkFetcher;
@protocol NetworkFetcherDelegate <NSObject>

@optional
- (void)resultsArray:(NSMutableArray *)array;
- (void)dataUpdated;

@end

@interface NetworkFetcher : NSObject

// Delegate id
@property (nonatomic, weak) id <NetworkFetcherDelegate> delegate;

// Designated initializer
- (instancetype)initWithURL:(NSURL *)dataURL;

@end
