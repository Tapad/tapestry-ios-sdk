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
 @param millisSinceRequestFirstInvoked the number of millisecond since the queueRequest was first invoked. Important because when requests may be queued when the device has no network connection, resulting in the callback running significantly later than expected.
 */
typedef void(^TATapestryResponseHandler)(TATapestryResponse* response, NSError* error, long millisSinceRequestFirstInvoked);

@interface TATapestryClientNG : NSObject

+ (TATapestryClientNG*)sharedClient;
- (void)setPartnerId:(NSString*)partnerId;
- (void)setBaseURL:(NSString*)baseURL;
- (void)setDefaultBaseURL;
- (void)queueRequest:(TATapestryRequest*)request;
- (void)queueRequest:(TATapestryRequest*)request withResponseBlock:(TATapestryResponseHandler)handler;

@end
