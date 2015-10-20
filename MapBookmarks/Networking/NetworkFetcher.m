//
//  NetworkFetcher.m
//  MapBookmarks
//
//  Created by Borys Khliebnikov on 10/19/15.
//  Copyright © 2015 Borys Khliebnikov. All rights reserved.
//

#import "NetworkFetcher.h"
#import "LocationObject.h"
#import <AFNetworking.h>

@interface NetworkFetcher ()
// Serialized data
@property (strong, nonatomic) NSMutableArray *results;

@end

@implementation NetworkFetcher


- (NSMutableArray *)results {
    if (!_results) {
        _results = [[NSMutableArray alloc] init];
    }
    return _results;
}

// Designated initializer
- (instancetype)initWithURL:(NSURL *)dataURL {
    self = [super init];
    if (self) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:dataURL];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                //NSLog(@"Response is %@\n Response object is %@", response, responseObject);
                NSArray *tempArray = [[responseObject objectForKey:@"response"]objectForKey:@"venues"];
                //NSLog(@"Response object is %@", [[self.results objectAtIndex:0]objectForKey:@"name"]);
                for (NSDictionary *locationData in tempArray)
                {
                    LocationObject *temp = [[LocationObject alloc] init];
                    temp.name            = [locationData objectForKey:@"name"];
                    [self.results addObject:temp];
                }
                // Updating table view !BACKGROUND!
                if([self.delegate respondsToSelector:@selector(resultsArray:)]) {
                    [self.delegate resultsArray:self.results];
                }
            }
        }];
        [dataTask resume];

    }
    return self;
}


@end
