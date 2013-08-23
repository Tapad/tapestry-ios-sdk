//
//  TATapestryClientNG.h
//  Tapestry
//
//  Created by Sveinung Kval Bakken on 30.07.13.
//  Copyright (c) 2013 Tapad. All rights reserved.
//

#import "TATapestryRequest.h"
#import "TATapestryResponse.h"
#import <Foundation/Foundation.h>

/**
 Type signature of Tapestry request callback.
 @param response The resulting data of the original request, or nil if there was an error.
 @param error Network error or json parsing error, or nil if response was successfully received.
 @param intervalSinceRequestFirstInvoked the interval since the queueRequest was first invoked. Important because when requests may be queued when the device has no network connection, resulting in the callback running significantly later than expected.
 */
typedef void(^TATapestryResponseHandler)(TATapestryResponse* response, NSError* error, NSTimeInterval intervalSinceRequestFirstInvoked);

/**
 The TATapestryClient actually sends Tapestry requests to the API and invokes the optional callback upon completion.
 It queues requests to execute asyncronously and concurrently, and handles retries if the network is unavailable.
 */
@interface TATapestryClientNG : NSObject

/**
  @return The shared client. Created exactly once.
 */
+ (TATapestryClientNG*)sharedClient;

/**
 Convenience function to set partner ID once, instead of on each request
 @param partnerId The partner ID
 */
- (void)setPartnerId:(NSString*)partnerId;
- (void)setBaseURL:(NSString*)baseURL;
- (void)setDefaultBaseURL;
- (void)queueRequest:(TATapestryRequest*)request;
- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler;


// Exposed for testing
- (NSOperationQueue*)test_requestQueue;

@end
