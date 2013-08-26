//
//  TATapestryClient.h
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
@interface TATapestryClient : NSObject
@property(nonatomic, copy) NSString* partnerId;
@property(nonatomic, copy) NSString* baseURL;

/**
  @return The shared client. Created exactly once.
 */
+ (TATapestryClient*)sharedClient;

/**
 Convenience function to set default partner ID once, instead of on each request. This partner ID will be added to each request, unless the request itself has one set.
 @param partnerId The partner ID
 */
- (void)setPartnerId:(NSString*)partnerId;

/**
 Queue and send a request, with no callback. If the network is unavilable, it will be automatically retried when the network becomes available again.
 @param request The request to send
 */
- (void)queueRequest:(TATapestryRequest*)request;

/**
 Queue and send a request, with a callback. If the network is unavilable, it will be automatically retried when the network becomes available again. The callback includes an "interval since first queued" argument, so the callback can abort if it executes later than expected.
 @param request The request to send
 @param handler The callback to invoke upon completion of the request.
 */
- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler;


// Exposed for testing
- (NSOperationQueue*)test_requestQueue;

@end
